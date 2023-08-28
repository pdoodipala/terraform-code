resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.private_subnets[0].id

  tags = {
    Name = nat
  }

  depends_on = [aws_internet_gateway.gw]
}
