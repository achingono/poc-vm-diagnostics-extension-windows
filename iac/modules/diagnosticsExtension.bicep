param name string
param location string 

var template = '''
<WadCfg> 
  <DiagnosticMonitorConfiguration overallQuotaInMB="4096" xmlns="http://schemas.microsoft.com/ServiceHosting/2010/10/DiagnosticsConfiguration"> <DiagnosticInfrastructureLogs scheduledTransferLogLevelFilter="Error"/> <WindowsEventLog scheduledTransferPeriod="PT1M" > <DataSource name="Application!*[System[(Level = 1 or Level = 2)]]" /> <DataSource name="Security!*[System[(Level = 1 or Level = 2)]]" /> <DataSource name="System!*[System[(Level = 1 or Level = 2)]]" /></WindowsEventLog>
  <PerformanceCounters scheduledTransferPeriod="PT1M"><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% Processor Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU utilization" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% Privileged Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU privileged time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% User Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU user time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor Information(_Total)\\Processor Frequency" sampleRate="PT15S" unit="Count"><annotation displayName="CPU frequency" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\System\\Processes" sampleRate="PT15S" unit="Count"><annotation displayName="Processes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Process(_Total)\\Thread Count" sampleRate="PT15S" unit="Count"><annotation displayName="Threads" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Process(_Total)\\Handle Count" sampleRate="PT15S" unit="Count"><annotation displayName="Handles" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\% Committed Bytes In Use" sampleRate="PT15S" unit="Percent"><annotation displayName="Memory usage" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Available Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Committed Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory committed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Commit Limit" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory commit limit" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active time" locale="en-us"/></PerformanceCounterConfiguration>
  <PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Read Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active read time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Write Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active write time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Transfers/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Reads/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk read operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Writes/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk write operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Read Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk read speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Write Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk write speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\LogicalDisk(_Total)\\% Free Space" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk free space (percentage)" locale="en-us"/></PerformanceCounterConfiguration></PerformanceCounters>
  <Metrics resourceId="${metricsresourceid}"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics></DiagnosticMonitorConfiguration>
</WadCfg>
'''

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: 'stg${replace(name,'-','')}'
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-03-01' existing = {
  name: 'vm-${name}'
}

resource diagnosticsSettings 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: virtualMachine
  name: 'Microsoft.Insights.VMDiagnosticsSettings'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'IaaSDiagnostics'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      xmlCfg: base64(replace(template, '\${metricsresourceid}', virtualMachine.id))
      StorageAccount: storageAccount.name
    }
    protectedSettings: {
      storageAccountName: storageAccount.name
      storageAccountKey: storageAccount.listKeys().keys[0].value
      storageAccountEndPoint: storageAccount.properties.primaryEndpoints.blob
    }
  }
}
