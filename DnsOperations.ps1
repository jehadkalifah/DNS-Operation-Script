$ZoneName=@()
$NetBoisName=@()
$IPAddress=@()
$NewIPAddress=@()
$NewPtrIPAddress=@() 
$RecordType=@()
$PTRZoneName=@()
$PTRName=@()
$NewPtrZoneName=@()
$ReverseRecordType=@()


Write-Host ("1) Get `n2) Add `n3) Update `n4) Delete`nPlease enter the correct execution number: ") -ForegroundColor Green -NoNewline 
$ExecutionNumber=Read-Host
#Delete with confirm

if ($ExecutionNumber -eq "1") {
   $DNSRecords=$null 
   $DNSRecords=Import-Csv -Path .\GetDnsRecords.csv 
   $DNSRecordsCount=($DNSRecords).Count
   $WhileCounter=0

   $DNSRecords | 
   ForEach-Object {
     $ZoneName += $_."Zone Name"
     $NetBoisName += $_."NetBois Name"
     $RecordType += $_."Record Type"
   }

   While ($WhileCounter -lt $DNSRecordsCount){ 
     Get-DnsServerResourceRecord -ZoneName $ZoneName[$WhileCounter] -RRType $RecordType[$WhileCounter] | ?{$_.HostName -like $NetBoisName[$WhileCounter]}

     $WhileCounter++
   }

}

elseif ($ExecutionNumber -eq "2") {
   $DNSRecords=$null 
   $DNSRecords=Import-Csv -Path .\AddDnsRecords.csv
   $DNSRecordsCount=($DNSRecords).Count
   $WhileCounter=0

   $DNSRecords | 
   ForEach-Object {
     $ZoneName += $_."Zone Name"
     $NetBoisName += $_."NetBois Name"
     $IPAddress += $_."IP Address"
   }

   While ($WhileCounter -lt $DNSRecordsCount){ 
     Add-DnsServerResourceRecordA -ZoneName $ZoneName[$WhileCounter] -Name $NetBoisName[$WhileCounter]  -IPv4Address $IPAddress[$WhileCounter] -CreatePtr

     $WhileCounter++
   }
}

elseif ($ExecutionNumber -eq "3") {
   $DNSRecords=$null 
   $DNSRecords=Import-Csv -Path .\UpdateDnsRecords.csv
   $DNSRecordsCount=($DNSRecords).Count
   $WhileCounter=0

   $DNSRecords | 
   ForEach-Object {
     $ZoneName += $_."Zone Name"
     $NetBoisName += $_."NetBois Name"
     $RecordType += $_."Record Type"
     $NewIPAddress += $_."New IP Address"
     $NewPtrIPAddress += $_."New Ptr IP Address (Last Octet)"
     $NewPtrZoneName += $_."New Ptr Zone Name" 
   }

   While ($WhileCounter -lt $DNSRecordsCount){ 
     $OldObj = $null
     $NewObj = $null 
     $PtrDomainNAme = $NetBoisName[$WhileCounter]+"."+$ZoneName[$WhileCounter]
     $OldObj = Get-DnsServerResourceRecord -ZoneName $ZoneName[$WhileCounter] -Name $NetBoisName[$WhileCounter] -RRType $RecordType[$WhileCounter]
     $NewObj = $OldObj.Clone()
     $NewObj.RecordData.Ipv4Address=[System.Net.IPAddress]::parse($NewIPAddress[$WhileCounter])
     Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName $ZoneName[$WhileCounter] 
     Add-DnsServerResourceRecordPtr -ZoneName $NewPtrZoneName[$WhileCounter] -Name $NewPtrIPAddress[$WhileCounter] -PtrDomainName $PtrDomainNAme -AllowUpdateAny
     $WhileCounter++
   }
}

elseif ($ExecutionNumber -eq "4") {
   $DNSRecords=$null 
   $DNSRecords=Import-Csv -Path .\DeleteDnsRecords.csv
   $DNSRecordsCount=($DNSRecords).Count
   $WhileCounter=0

   $DNSRecords | 
   ForEach-Object {
     $ZoneName += $_."Zone Name"
     $NetBoisName += $_."NetBois Name"
     $RecordType += $_."Record Type"
     $PTRZoneName += $_."PTR Zone Name"
     $PTRName += $_."PTR Name"
     $ReverseRecordType += $_."Reverse Record Type"
   }

   While ($WhileCounter -lt $DNSRecordsCount){ 
     Remove-DnsServerResourceRecord -ZoneName $PTRZoneName[$WhileCounter] -Name $PTRName[$WhileCounter] -RRType $ReverseRecordType[$WhileCounter]
     Remove-DnsServerResourceRecord -ZoneName $ZoneName[$WhileCounter] -Name $NetBoisName[$WhileCounter] -RRType $RecordType[$WhileCounter] 

     $WhileCounter++
   }
}

else {
    Write-Host ("Please enter the correct execution number") -ForegroundColor Red
}

