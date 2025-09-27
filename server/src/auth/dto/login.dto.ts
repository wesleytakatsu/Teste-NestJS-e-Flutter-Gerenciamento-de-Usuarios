import { IsEmail, IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({
    example: 'admin@conectar.com',
    description: 'Email do usuário para login'
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'admin123',
    description: 'Senha do usuário'
  })
  @IsString()
  @IsNotEmpty()
  password: string;
}