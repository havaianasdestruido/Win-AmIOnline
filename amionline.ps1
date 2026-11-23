# Monitor de conexão com notificações de estado
# Salve como Monitor-Internet.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Target = "8.8.8.8"
$IntervalSeconds = 1
$TimeoutMs = 1000

# Cria um único ícone na área de notificação
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$NotifyIcon.Icon = [System.Drawing.SystemIcons]::Application
$NotifyIcon.Text = "Monitor de Internet"
$NotifyIcon.Visible = $true

# Estado inicial desconhecido: a primeira resposta gera notificação
$LastState = $null

try {
    while ($true) {
        $Ping = New-Object System.Net.NetworkInformation.Ping
        $CurrentState = "Offline"

        try {
            $Reply = $Ping.Send($Target, $TimeoutMs)

            if ($Reply.Status -eq
                [System.Net.NetworkInformation.IPStatus]::Success) {
                $CurrentState = "Online"
            }
        }
        catch {
            $CurrentState = "Offline"
        }
        finally {
            $Ping.Dispose()
        }

        # Notifica apenas na primeira verificação ou quando muda de estado
        if ($CurrentState -ne $LastState) {
            if ($CurrentState -eq "Online") {
                $NotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
                $NotifyIcon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
                $NotifyIcon.BalloonTipTitle = "Internet online"
                $NotifyIcon.BalloonTipText = "$Target respondeu ao ping."
            }
            else {
                $NotifyIcon.Icon = [System.Drawing.SystemIcons]::Warning
                $NotifyIcon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
                $NotifyIcon.BalloonTipTitle = "Internet offline"
                $NotifyIcon.BalloonTipText = "Sem resposta de $Target."
            }

            $NotifyIcon.ShowBalloonTip(3000)
            $LastState = $CurrentState
        }

        Start-Sleep -Seconds $IntervalSeconds
    }
}
finally {
    $NotifyIcon.Visible = $false
    $NotifyIcon.Dispose()
}