import { Body, Controller, Post } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ 
    summary: 'Registrar novo usuário',
    description: 'Cria uma nova conta de usuário no sistema' 
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Usuário registrado com sucesso',
    example: {
      id: 'cmg1exstb0001wsyvj2dlgf6g',
      name: 'João Silva',
      email: 'joao.silva@exemplo.com',
      role: 'user',
      createdAt: '2025-09-26T22:28:05.280Z',
      updatedAt: '2025-09-26T22:31:11.090Z'
    }
  })
  @ApiResponse({ status: 400, description: 'Dados inválidos ou email já existe' })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @ApiOperation({ 
    summary: 'Fazer login',
    description: 'Autentica o usuário e retorna token JWT para acesso às rotas protegidas' 
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Login realizado com sucesso',
    example: {
      access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      user: {
        id: 'cmg1exsrc0000wsyvghctqgnp',
        name: 'Admin User',
        email: 'admin@conectar.com',
        role: 'admin'
      }
    }
  })
  @ApiResponse({ status: 401, description: 'Credenciais inválidas' })
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }
}
