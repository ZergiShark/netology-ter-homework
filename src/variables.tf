###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "image_id" {
  default = "fd8g64rcu9fq5kpfqls0"
}

variable "subnet_id" {
  default = yandex_vpc_subnet.develop.id
}

variable "ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "disk_count" {
  description = "Количество дисков для создания"
  type        = number
  default     = 3
}

variable "disk_name_prefix" {
  description = "Префикс имени диска"
  type        = string
  default     = "disk"
}

variable "disk_size_gb" {
  description = "Размер диска в гигабайтах"
  type        = number
  default     = 1
}

variable "instance_name" {
  description = "Имя виртуальной машины storage"
  type        = string
  default     = "storage"
}

variable "instance_name_disk" {
  description = "Имя виртуальной машины disk"
  type        = string
  default     = "disk"
}

variable "instance_cores" {
  description = "Количество ядер процессора"
  type        = number
  default     = 2
}

variable "instance_memory" {
  description = "Объем памяти в гигабайтах"
  type        = number
  default     = 1
}

variable "instance_core_fraction" {
  description = "Доля процессора"
  type        = number
  default     = 5
}

variable "instance_count" {
  description = "Количество ВМ"
  type        = number
  default     = 2
}

variable "name_prefix" {
  description = "Prefix for instance name"
  default     = "develop"
}

variable "ssh_user" {
  description = "SSH user for the instance"
  default     = "ubuntu"
}