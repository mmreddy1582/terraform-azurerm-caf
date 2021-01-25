resource "azurerm_dns_a_record" "a" {
  for_each = {
    for key, value in try(var.records.a, {}) : key => value
    if try(value.resource_id, null) == null
  }

  name                = each.value.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = try(each.value.ttl, 300)
  records             = try(each.value.records, null)
  tags                = merge(try(each.value.tags, {}), var.base_tags)
}

resource "azurerm_dns_a_record" "a_dns_zone_record" {
  for_each = {
    for key, value in try(var.records.a, {}) : key => value
    if try(value.resource_id, null) != null
  }

  name                = each.value.name
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300                                                                                 # Looks like cannot set another value than 300 when using target_resource_id
  tags                = merge(try(each.value.tags, {}), var.base_tags)
  target_resource_id  = azurerm_dns_a_record.a[each.value.resource_id.dns_zone_record.key].id
}