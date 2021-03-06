<#
Copyright 2016 ASOS.com Limited

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

<#
.NAME
	New-StepTemplateObject.Tests

.SYNOPSIS
	Pester tests for New-StepTemplateObject.
#>
Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
. "$here\..\..\PowerShellManipulation\Get-VariableFromScriptFile.ps1"
. "$here\..\..\PowerShellManipulation\Get-ScriptBody.ps1"

Describe "New-StepTemplateObject" {
    Mock Get-ScriptBody {}
    Mock Get-VariableFromScriptFile {}
    
    It "Should return a new object with the name from the script file" {
        Mock Get-VariableFromScriptFile { "test name" } -ParameterFilter { $Path -eq "TestDrive:\file.ps1" -and $VariableName -eq "StepTemplateName" } -Verifiable
        
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % Name | Should Be "test name"
        
        Assert-VerifiableMocks
    }
    
    It "Should return a new object with the description from the script file" {
        Mock Get-VariableFromScriptFile { "test description" } -ParameterFilter { $Path -eq "TestDrive:\file.ps1" -and $VariableName -eq "StepTemplateDescription" } -Verifiable
        
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % Description | Should Be "test description"
        
        Assert-VerifiableMocks
    }
    
    It "Should return a new object with the action type of octopus.script" {      
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % ActionType | Should Be "Octopus.Script"
    }
    
    It "Should return a new object with the property Octopus.Action.Script.ScriptBody from the script file" {      
        Mock Get-ScriptBody { "test script" } -ParameterFilter { $Path -eq "TestDrive:\file.ps1" } -Verifiable
        
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % Properties | % 'Octopus.Action.Script.ScriptBody' | Should Be "test script"
        
        Assert-VerifiableMocks
    }
    
    It "Should return a new object with the property Octopus.Action.Script.Syntax of PowerShell" {      
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % Properties | % 'Octopus.Action.Script.Syntax' | Should Be "PowerShell"
    }
    
    It "Should return a new object with the parameters from the script file" {
        Mock Get-VariableFromScriptFile { "test parameters" } -ParameterFilter { $Path -eq "TestDrive:\file.ps1" -and $VariableName -eq "StepTemplateParameters" } -Verifiable
        
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % Parameters | Should Be @("test parameters")
        
        Assert-VerifiableMocks
    }
    
    It "Should return a new object with the SensitiveProperties an empty hashtable" {      
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % 'SensitiveProperties' | % GetType | % Name | Should Be 'hashtable'
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % 'SensitiveProperties' | % Count | Should Be 0 
    }
    
    It "Should return a new object with the metatype of actiontemplate" {      
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % '$Meta' | % 'Type' | Should Be 'ActionTemplate'
    }
    
    It "Should return a new object with the version of 1" {      
        New-StepTemplateObject -Path "TestDrive:\file.ps1" | % 'Version' | Should Be 1
    }
}
