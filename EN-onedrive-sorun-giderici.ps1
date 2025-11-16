Add-Type -AssemblyName PresentationFramework

$OneDrivePath = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"

function Show-Message($msg, $title="Info") {
    [System.Windows.MessageBox]::Show($msg, $title, "OK", "Information") | Out-Null
}

function Check-OneDrive {
    $process = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
    if ($process) {
        Show-Message "✅ OneDrive is currently running. (PID: $($process.Id))" "Status Check"
    } else {
        Show-Message "⚠️ OneDrive is not running." "Status Check"
    }
}

function Stop-OneDrive {
    try {
        Stop-Process -Name "OneDrive" -Force -ErrorAction Stop
        Show-Message "⛔ OneDrive has been stopped successfully." "Stop"
    } catch {
        Show-Message "❌ OneDrive is already stopped or could not be stopped." "Stop Error"
    }
}

function Start-OneDrive {
    if (Test-Path $OneDrivePath) {
        Start-Process $OneDrivePath
        Show-Message "▶️ OneDrive has been restarted." "Restart"
    } else {
        Show-Message "❌ OneDrive.exe not found: $OneDrivePath" "Start Error"
    }
}

function Reset-OneDrive {
    if (Test-Path $OneDrivePath) {
        & $OneDrivePath /reset
        Show-Message "🔄 OneDrive has been reset. Restarting..." "Reset"
        Start-Sleep -Seconds 3
        Start-OneDrive
    } else {
        Show-Message "❌ OneDrive.exe not found: $OneDrivePath" "Reset Error"
    }
}

function Fix-All {
    Check-OneDrive
    Stop-OneDrive
    Start-OneDrive
    Reset-OneDrive
    Show-Message "✅ All operations completed successfully." "Batch Operation"
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="💼 OneDrive Troubleshooter"
        MinWidth="400" MinHeight="400"
        Height="450" Width="450"
        Background="#f8f8f8"
        ResizeMode="CanResizeWithGrip"
        WindowStartupLocation="CenterScreen">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0"
                   Text="💼 www.arifakyuz.com | OneDrive Troubleshooter"
                   FontSize="15"
                   FontWeight="Bold"
                   TextAlignment="Center"
                   Margin="0,0,0,15"
                   HorizontalAlignment="Center"/>

        <StackPanel Grid.Row="1" VerticalAlignment="Center" HorizontalAlignment="Center" Width="Auto">
            <Button Name="btnCheck" Content="🔍 Check Status" Height="40" Margin="5" Padding="10,5"/>
            <Button Name="btnStop" Content="⛔ Stop OneDrive" Height="40" Margin="5" Padding="10,5"/>
            <Button Name="btnStart" Content="▶️ Start OneDrive" Height="40" Margin="5" Padding="10,5"/>
            <Button Name="btnReset" Content="🔄 Reset OneDrive" Height="40" Margin="5" Padding="10,5"/>
        </StackPanel>

        <Button Grid.Row="2"
                Name="btnFixAll"
                Content="🧰 Run All Steps"
                Height="45"
                Margin="0,20,0,0"
                Background="#0078D7"
                Foreground="White"
                FontWeight="Bold"
                HorizontalAlignment="Center"
                Padding="20,5"/>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$window.FindName("btnCheck").Add_Click({ Check-OneDrive })
$window.FindName("btnStop").Add_Click({ Stop-OneDrive })
$window.FindName("btnStart").Add_Click({ Start-OneDrive })
$window.FindName("btnReset").Add_Click({ Reset-OneDrive })
$window.FindName("btnFixAll").Add_Click({ Fix-All })

$window.ShowDialog() | Out-Null
