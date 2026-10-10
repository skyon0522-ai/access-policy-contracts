param(
    [Parameter(Mandatory = $true)]
    [string] $Opa,
    [string] $OutputDirectory = 'examples'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$opaPath = (Resolve-Path -LiteralPath $Opa).Path
$expectedHash = '98ac401e944f6bc9bbc29a91f699b3403ec6979ed94682e46fa5ec78a8230bf3'
$actualHash = (Get-FileHash -LiteralPath $opaPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $expectedHash) { throw 'OPA executable checksum mismatch; use official Windows amd64 v0.67.0.' }

$source = Join-Path $root 'components/contrib/academy-samples/opa-by-example/review_authz_example/rules_and_data'
$main = Join-Path $source 'main/rules.rego'
$role = Join-Path $source 'policy/role/rules.rego'
$contract = Join-Path $root 'contract/contract.rego'
$test = Join-Path $root 'contract/contract_test.rego'

$testOutput = & $opaPath test -v $source $contract $test 2>&1
if ($LASTEXITCODE -ne 0) { throw "OPA policy tests failed: $testOutput" }
$testSummary = [regex]::Match(($testOutput -join "`n"), 'PASS:\s+(\d+)/(\d+)')
if (-not $testSummary.Success -or $testSummary.Groups[1].Value -ne '51' -or $testSummary.Groups[2].Value -ne '51') {
    throw "Expected the complete 51-test policy suite; got: $testOutput"
}

$cases = @(
    @{ id = 'same-tenant-review'; label = 'Customer review in the same tenant'; input = 'examples/same-tenant-review.json'; expected = $true; reason = 'The tenant gate passes and the customer-review rule accepts numeric reputation 10.' },
    @{ id = 'cross-tenant-admin-delete'; label = 'Admin delete across tenants'; input = 'examples/cross-tenant-admin-delete.json'; expected = $false; reason = 'The tenant gate rejects different subject and resource tenants before delegation.' },
    @{ id = 'admin-delete'; label = 'Admin delete without reputation'; input = 'examples/admin-delete.json'; expected = $true; reason = 'An omitted reputation is permitted for an admin; the role rule accepts admin.' },
    @{ id = 'admin-string-reputation'; label = 'Admin delete with string reputation'; input = 'examples/admin-string-reputation.json'; expected = $false; reason = 'A supplied reputation must be numeric, even for an admin.' }
)

$results = foreach ($case in $cases) {
    $inputPath = Join-Path $root $case.input
    $raw = & $opaPath eval --strict-builtin-errors --format raw --input $inputPath --data $main --data $role --data $contract 'data.access_contract.allow' 2>&1
    if ($LASTEXITCODE -ne 0) { throw "OPA evaluation failed for $($case.id): $raw" }
    $value = ([string] $raw).Trim()
    if ($value -notin @('true', 'false')) { throw "Expected a boolean OPA decision for $($case.id), got: $value" }
    $actual = $value -eq 'true'
    if ($actual -ne $case.expected) { throw "Unexpected decision for $($case.id): $value" }
    [ordered]@{
        case = $case.id
        label = $case.label
        input = $case.input
        input_json = [IO.File]::ReadAllText($inputPath, [Text.Encoding]::UTF8)
        decision = $actual
        explanation = $case.reason
    }
}

$report = [ordered]@{
    policy_query = 'data.access_contract.allow'
    opa_version = '0.67.0'
    opa_sha256 = $actualHash
    test_summary = "$($testSummary.Groups[1].Value) passed, 0 failed"
    cases = @($results)
}
$output = if ([IO.Path]::IsPathRooted($OutputDirectory)) { $OutputDirectory } else { Join-Path $root $OutputDirectory }
New-Item -ItemType Directory -Path $output -Force | Out-Null
$jsonPath = Join-Path $output 'decision-results.json'
$htmlPath = Join-Path $output 'decision-matrix.html'
$json = $report | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($jsonPath, $json + "`n", [Text.UTF8Encoding]::new($false))

$rows = foreach ($case in $results) {
    $label = [Net.WebUtility]::HtmlEncode($case.label)
    $input = [Net.WebUtility]::HtmlEncode($case.input)
    $inputJson = [Net.WebUtility]::HtmlEncode($case.input_json)
    $reason = [Net.WebUtility]::HtmlEncode($case.explanation)
    $decision = if ($case.decision) { 'Allow' } else { 'Deny' }
    "<tr><th scope='row'>$label</th><td><code>$input</code><details><summary>View evaluated JSON</summary><pre>$inputJson</pre></details></td><td><strong>$decision</strong></td><td>$reason</td></tr>"
}
$body = $rows -join "`n"
$html = @"
<!doctype html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Access policy decision walkthrough</title>
<style>
body{font:16px/1.55 system-ui,sans-serif;max-width:74rem;margin:0 auto;padding:2rem 1rem;color:#17212b;background:#f7f9fc}
main{background:white;padding:1.5rem;border:1px solid #d5deea;border-radius:.6rem;min-width:0}
h1{line-height:1.2}p{max-width:75ch}table{border-collapse:collapse;width:100%;min-width:40rem}th,td{text-align:left;vertical-align:top;padding:.7rem;border-bottom:1px solid #d5deea}thead{background:#edf2f8}.scroll{overflow:auto;max-width:100%}.scroll:focus-visible,summary:focus-visible,a:focus-visible{outline:3px solid #124c82;outline-offset:2px}summary{cursor:pointer;padding:.4rem 0}pre{white-space:pre-wrap;overflow-wrap:anywhere}code{overflow-wrap:anywhere}a{color:#124c82}
@media(max-width:600px){body{padding:1rem .5rem}main{padding:1rem}}
@media print{body{background:white;padding:0}main{border:0;padding:0}}
</style>
<main>
<h1>Access policy decision walkthrough</h1>
<p>Four synthetic requests evaluated by the real OPA review/delete rules through <code>contract/contract.rego</code>. A decision is a policy result, not proof that a caller authenticated the subject or enforced it in an application.</p>
<div class="scroll" role="region" aria-label="Policy decision table" tabindex="0"><table><thead><tr><th scope="col">Request</th><th scope="col">Input</th><th scope="col">Decision</th><th scope="col">Why</th></tr></thead><tbody>
$body
</tbody></table></div>
<p>OPA 0.67.0 Windows amd64, SHA-256 <code>$actualHash</code>. The full policy suite passed 51 tests. <a href="decision-results.json">Inspect the exact machine-readable decisions</a>.</p>
<p>The caller must supply trusted tenant, role and reputation attributes. Undefined, errored or nonboolean responses must never authorize an operation.</p>
</main>
</html>
"@
[IO.File]::WriteAllText($htmlPath, $html + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "Policy tests: $($report.test_summary)"
foreach ($case in $results) { Write-Output "$($case.case): $($case.decision.ToString().ToLowerInvariant())" }
Write-Output "Saved $jsonPath and $htmlPath"
