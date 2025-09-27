import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';

@ApiTags('📋 Informações da API')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ 
    summary: 'Informações da API',
    description: 'Retorna informações básicas e instruções de uso da API' 
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Informações da API',
    example: {
      message: 'Conectar API - Sistema de Gerenciamento de Usuários',
      version: '1.0',
      documentation: 'http://localhost:3000/api',
      testUser: {
        email: 'admin@conectar.com',
        password: 'admin123',
        role: 'admin'
      },
      instructions: [
        '1. Faça POST /auth/login com as credenciais de teste',
        '2. Copie o access_token da resposta',
        '3. Use o token no cabeçalho: Authorization: Bearer {token}',
        '4. Acesse /api para documentação completa no Swagger'
      ]
    }
  })
  getHello(): object {
    return {
      message: 'Conectar API - Sistema de Gerenciamento de Usuários',
      version: '1.0',
      documentation: 'http://localhost:3000/api',
      testUser: {
        email: 'admin@conectar.com',
        password: 'admin123',
        role: 'admin'
      },
      instructions: [
        '1. Faça POST /auth/login com as credenciais de teste',
        '2. Copie o access_token da resposta', 
        '3. Use o token no cabeçalho: Authorization: Bearer {token}',
        '4. Acesse /api para documentação completa no Swagger'
      ],
      endpoints: {
        auth: ['/auth/login', '/auth/register'],
        users: ['/users', '/users/profile', '/users/inactive'],
        swagger: '/api'
      }
    };
  }
}
