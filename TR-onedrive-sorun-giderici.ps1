Add-Type -AssemblyName PresentationFramework

$OneDrivePath = "C:\Program Files\Microsoft OneDrive\OneDrive.exe"

function Show-Message($msg, $title="Bilgi") {
    [System.Windows.MessageBox]::Show($msg, $title, "OK", "Information") | Out-Null
}

function Check-OneDrive {
    $process = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
    if ($process) {
        Show-Message "✅ OneDrive şu anda çalışıyor. (PID: $($process.Id))" "Durum Kontrolü"
    } else {
        Show-Message "⚠️ OneDrive çalışmıyor." "Durum Kontrolü"
    }
}

function Stop-OneDrive {
    try {
        Stop-Process -Name "OneDrive" -Force -ErrorAction Stop
        Show-Message "⛔ OneDrive başarıyla durduruldu." "Durdurma"
    } catch {
        Show-Message "❌ OneDrive zaten kapalı veya durdurulamadı." "Durdurma Hatası"
    }
}

function Start-OneDrive {
    if (Test-Path $OneDrivePath) {
        Start-Process $OneDrivePath
        Show-Message "▶️ OneDrive yeniden başlatıldı." "Yeniden Başlatma"
    } else {
        Show-Message "❌ OneDrive.exe bulunamadı: $OneDrivePath" "Başlatma Hatası"
    }
}

function Reset-OneDrive {
    if (Test-Path $OneDrivePath) {
        & $OneDrivePath /reset
        Show-Message "🔄 OneDrive sıfırlandı. Yeniden başlatılıyor..." "Sıfırlama"
        Start-Sleep -Seconds 3
        Start-OneDrive
    } else {
        Show-Message "❌ OneDrive.exe bulunamadı: $OneDrivePath" "Sıfırlama Hatası"
    }
}

function Fix-All {
    Check-OneDrive
    Stop-OneDrive
    Start-OneDrive
    Reset-OneDrive
    Show-Message "✅ Tüm işlemler başarıyla tamamlandı." "Toplu İşlem"
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="💼 OneDrive Sorun Giderici"
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
                   Text="💼 www.arifakyuz.com - OneDrive Sorun Giderici"
                   FontSize="15"
                   FontWeight="Bold"
                   TextAlignment="Center"
                   Margin="0,0,0,15"
                   HorizontalAlignment="Center"/>

        <StackPanel Grid.Row="1" VerticalAlignment="Center" HorizontalAlignment="Center" Width="Auto">
            <Button Name="btnCheck" Content="🔍 Durumu Kontrol Et" Height="40" Margin="5" Padding="10,5"/>
            <Button Name="btnStop" Content="⛔ OneDrive'ı Durdur" Height="40" Margin="5" Padding="10,5"/>
            <Button Name="btnStart" Content="▶️ OneDrive'ı Başlat" Height="40" Margin="5" Padding="10,5"/>
            <Button Name="btnReset" Content="🔄 OneDrive'ı Sıfırla" Height="40" Margin="5" Padding="10,5"/>
        </StackPanel>

        <Button Grid.Row="2"
                Name="btnFixAll"
                Content="🧰 Tümünü Sırayla Yap"
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
