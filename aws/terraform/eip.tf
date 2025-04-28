resource "aws_eip_association" "dseipassoc" {
  network_interface_id = aws_network_interface.dataserver-netif0.id
  allocation_id = "eipalloc-0bbedcf658d565051"
}
