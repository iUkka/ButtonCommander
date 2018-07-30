param ( $team_domain )
Write-Output "You passed $($args.Count) arguments:"
$args | Write-Output
write-output "Named param  team_domain is $team_domain"
