import { IsEmail, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({
    example: 'João Silva',
    description: 'Nome completo do usuário'
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    example: 'joao.silva@exemplo.com',
    description: 'Email único do usuário'
  })
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'minhasenha123',
    description: 'Senha do usuário (mínimo 6 caracteres)'
  })
  @IsString()
  @IsNotEmpty()
  password: string;

  @ApiProperty({
    example: 'user',
    description: 'Papel do usuário (admin ou user)',
    required: false,
    enum: ['admin', 'user']
  })
  @IsOptional()
  @IsString()
  role?: string;
}