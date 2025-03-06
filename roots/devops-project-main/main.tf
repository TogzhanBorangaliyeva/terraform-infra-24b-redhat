# DO NOT REMOVE DUMMY MODULE references and their code, they should remain as examples
module "module1" {
  source = "../../dummy-module"
  # ... any required variables for module1
  greeting = var.greeting

}