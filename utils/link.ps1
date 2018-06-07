Set-Location -Path "$PSScriptRoot\.."

If(-Not (Test-Path -Path "libs")){
	New-Item -ItemType Directory -Path libs
}

If(-Not (Test-Path -Path "libs\LibStub")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibStub -Value ..\LibStub
} ElseIf(-Not (((Get-Item -Path "libs\LibStub").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\LibStub"
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibStub -Value ..\LibStub
}

If(-Not (Test-Path -Path "libs\LibGossipQuestInfo")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibGossipQuestInfo -Value ..\LibGossipQuestInfo
} ElseIf(-Not (((Get-Item -Path "libs\LibGossipQuestInfo").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\LibGossipQuestInfo"
	New-Item -ItemType SymbolicLink -Path "libs" -Name LibGossipQuestInfo -Value ..\LibGossipQuestInfo
}

If(-Not (Test-Path -Path "libs\Wasabi")){
	New-Item -ItemType SymbolicLink -Path "libs" -Name Wasabi -Value ..\Wasabi
} ElseIf(-Not (((Get-Item -Path "libs\Wasabi").Attributes.ToString()) -Match "ReparsePoint")){
	Remove-Item -Path "libs\Wasabi"
	New-Item -ItemType SymbolicLink -Path "libs" -Name Wasabi -Value ..\Wasabi
}
