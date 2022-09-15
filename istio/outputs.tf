output "random_prefix" {
  value       = random_string.random.result
  description = "Specifies the random value that is used as a prefix for the name of all the Azure resources when not explicitly defined in variables."
}