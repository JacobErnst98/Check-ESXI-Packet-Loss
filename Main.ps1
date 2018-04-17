<#
.SYNOPSIS
  Checks VDI Packet loss
.DESCRIPTION
Outputs VDI packet loss to a file
.INPUTS
  None
.OUTPUTS
Loss file
.NOTES

  INFO
    Version:        2.1
    Author:         Jacob Ernst
    Modification Date:  4/17/2018
    Purpose/Change: Sanitise For Git
    Modules:        Vmware* (PowerCLI)


  BUGS
    Count only updates do not show unless you move the mouse
#>



#Gui and Asymbly types for the form

Add-Type -AssemblyName System.Windows.Forms




#Function to show indows file picker
 Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 return $OpenFileDialog.filename
 
} #end function Get-FileName



#Windows Form Stuff
$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Form"
$Form.TopMost = $true
$Form.Width = 400
$Form.Height = 666

$Server = New-Object system.windows.Forms.Label
$Server.Text = "Server"
$Server.AutoSize = $true
$Server.Width = 25
$Server.Height = 10
$Server.location = new-object system.drawing.point(28,10)
$Server.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($Server)

$Serv = New-Object system.windows.Forms.TextBox
$Serv.Width = 200
$Serv.Height = 20
$Serv.location = new-object system.drawing.point(28,30)
$Serv.Font = "Microsoft Sans Serif,10"
$Serv.Text = "vcenter.example.com"
$Form.controls.Add($Serv)

$User = New-Object system.windows.Forms.Label
$User.Text = "User"
$User.AutoSize = $true
$User.Width = 25
$User.Height = 10
$User.location = new-object system.drawing.point(28,50)
$User.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($User)

$Usr = New-Object system.windows.Forms.TextBox
$Usr.Width = 200
$Usr.Height = 20
$Usr.location = new-object system.drawing.point(28,70)
$Usr.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($Usr)

$Password = New-Object system.windows.Forms.Label
$Password.Text = "Password"
$Password.AutoSize = $true
$Password.Width = 25
$Password.Height = 10
$Password.location = new-object system.drawing.point(28,90)
$Password.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($Password)

$Passwd = New-Object system.windows.Forms.MaskedTextBox
$Passwd.Width = 200
$Passwd.Height = 20
$Passwd.location = new-object system.drawing.point(28,110)
$Passwd.Font = "Microsoft Sans Serif,10"
$Passwd.PasswordChar = '*'
$Passwd.Visible = "false"
$Form.controls.Add($Passwd)

$button1 = New-Object system.windows.Forms.Button
$button1.Text = "Go!"
$button1.Width = 146
$button1.Height = 20
$button1.location = new-object system.drawing.point(28,290)
$button1.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($button1)

$startlabel = New-Object system.windows.Forms.Label
$startlabel.Text = "Start Date ex: 09/28/17 14:30"
$startlabel.AutoSize = $true
$startlabel.Width = 25
$startlabel.Height = 10
$startlabel.location = new-object system.drawing.point(28,130)
$startlabel.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($startlabel)

$StartDate = New-Object system.windows.Forms.TextBox
$StartDate.Width = 200
$StartDate.Height = 20
$StartDate.location = new-object system.drawing.point(28,150)
$StartDate.Font = "Microsoft Sans Serif,10"
$StartDate.Text = "09/28/17 14:30"
$Form.controls.Add($StartDate)

$vmcountout = New-Object system.windows.Forms.Label
$vmcountout.Text = "Vm Count"
$vmcountout.AutoSize = $true
$vmcountout.Width = 25
$vmcountout.Height = 10
$vmcountout.location = new-object system.drawing.point(28,310)
$vmcountout.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($vmcountout)

$LT = New-Object system.windows.Forms.Label
$LT.Text = "Loss Threshold"
$LT.AutoSize = $true
$LT.Width = 25
$LT.Height = 10
$LT.location = new-object system.drawing.point(28,170)
$LT.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($LT)

$loss = New-Object system.windows.Forms.TextBox
$loss.Text = "0"
$loss.Width = 200
$loss.Height = 20
$loss.location = new-object system.drawing.point(28,200)
$loss.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($loss)



echo "1"


#get file name
$File = $(Get-FileName -initialDirectory "c:")
																											


#Button for some clicky clicky action
$button1.Add_click({
	
	echo "1.4"



#Get user input
	$server = $Serv.Text
$password = $Passwd.Text
$user = $Usr.Text

#Connect to server
Connect-VIServer -Server $server -Protocol https -User $user -Password $password

#Set vars
$start = Get-Date $StartDate.Text
$finish = Get-Date 
$esx = Get-VMHost 
$vmcount = 0
$LTH = $loss.Text
	echo "2"


#for every host in every cluster 
foreach($esx in (Get-VMHost)){
    $vms = Get-VM -Location $esx
    Echo "$esx" | Out-File $File -Append -Encoding UTF8
    if($vms){
    #for every vm in every host
      foreach($vms in $vms){

      #Echo every packet drop
       $vms  | Select PowerState,Version, Guest | Out-File $File -Append -Encoding UTF8 -Width 200
       Get-Stat -Entity $vms -Stat *.summation -Start $start -Finish $finish | Where MetricId -like "*net.dropped*" | where Value -ne 0 | select Value, MetricId, Timestamp, Entity | Where Value -gt $LTH | Out-File $File -Append -Encoding UTF8
       
       $vmcount = $vmcount+1
	   $vmcountout.text = "$vmcount"
	   
    }
    } 
    }
	$vmcountout.Text = "done"
	}
)
[void]$Form.ShowDialog()
