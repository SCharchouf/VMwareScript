GET-VMHost -PipelineVariable esx |
ForEach-Object -Process {
    $esxcli = Get-Esxcli -VMHost $esx -V2

    #Standard Switch 상태 확인
    $esxcli.network.vswitch.standard.list.Invoke() |
    ForEach-Object -Process {
        $vss = $_
        $vss.Uplinks | where {$_ -ne $null} | %{
            $nic = $_
            $netAdapt = Get-VMHostNetworkAdapter -VMHost $esxcli.VMHost -Name $nic
            $nicList = $esxcli.network.nic.list.Invoke() | where{$_.Name -eq $nic}

            echo "#### [$esx] Standard switch check......"

            #상태 down인 Standard switch 정보 확인
            $esxcli.network.nic.get.Invoke(@{nicname="$_"}) | where{$_.linkstatus -eq "down"} |
            Select @{N='VMHost';E={$esx.Name}},
                @{N='Switch';E={$vss.Name}},
                @{N='NIC';E={$nic}},
                @{N='MTU';E={$vss.MTU}},
                @{N='Linkstatus';E={$_.linkstatus}}

        }
    }

    #vds 상태 확인
    $esxcli.network.vswitch.dvs.vmware.list.Invoke() |
    ForEach-Object -Process {
        $vds = $_
        $vds.Uplinks | where {$_ -ne $null} | %{
            $nic = $_
            $netAdapt = Get-VMHostNetworkAdapter -VMHost $esxcli.VMHost -Name $nic
            $nicList = $esxcli.network.nic.list.Invoke() | where{$_.Name -eq $nic}

            echo "#### [$esx] vds check......"

            #상태 down인 vds 정보 확인
            $esxcli.network.nic.get.Invoke(@{nicname="$_"}) | where{$_.linkstatus -eq "down"} |
            Select @{N='VMHost';E={$esx.Name}},
                @{N='Switch';E={$vds.Name}},
                @{N='NIC';E={$nic}},
                @{N='MTU';E={$vds.MTU}},
                @{N='Linkstatus';E={$_.linkstatus}}

        }
    }
}
