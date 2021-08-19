
output "sec_grp_ids" {
  description = "AWS Security group properties"
  value = aws_security_group.main.*.id
}

output "sec_grps" {
  description = "AWS Security group properties"
  # value = {
  #   "NAME" = tolist(aws_security_group.main.*.name)
  #   "ID"   = aws_security_group.main.*.id
  # }
  value = zipmap(aws_security_group.main.*.name,aws_security_group.main.*.id)
}