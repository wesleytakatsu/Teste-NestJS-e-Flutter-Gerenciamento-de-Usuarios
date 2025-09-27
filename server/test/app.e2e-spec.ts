import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from './../src/app.module';
import { PrismaService } from '../src/prisma/prisma.service';
import * as bcrypt from 'bcrypt';

describe('AppController (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let adminToken: string;
  let userToken: string;
  let userId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe());
    await app.init();

    prisma = moduleFixture.get<PrismaService>(PrismaService);

    // Clear database and create test users
    await prisma.user.deleteMany();
    
    const hashedPassword = await bcrypt.hash('password123', 10);
    
    // Create admin user
    await prisma.user.create({
      data: {
        name: 'Admin Test',
        email: 'admin@test.com',
        password: hashedPassword,
        role: 'admin',
      },
    });

    // Create regular user
    const user = await prisma.user.create({
      data: {
        name: 'User Test',
        email: 'user@test.com',
        password: hashedPassword,
        role: 'user',
      },
    });
    userId = user.id;

    // Create inactive user (for testing inactive users endpoint)
    await prisma.user.create({
      data: {
        name: 'Inactive User',
        email: 'inactive@test.com',
        password: hashedPassword,
        role: 'user',
        lastLogin: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000), // 45 days ago
      },
    });
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Hello World!');
  });

  describe('Authentication', () => {
    it('/auth/register (POST)', () => {
      return request(app.getHttpServer())
        .post('/auth/register')
        .send({
          name: 'New User',
          email: 'newuser@test.com',
          password: 'password123',
          role: 'user',
        })
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body).toHaveProperty('name', 'New User');
          expect(res.body).toHaveProperty('email', 'newuser@test.com');
          expect(res.body).toHaveProperty('role', 'user');
          expect(res.body).not.toHaveProperty('password');
        });
    });

    it('/auth/login (POST) - Admin', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'admin@test.com',
          password: 'password123',
        })
        .expect(200);

      expect(response.body).toHaveProperty('access_token');
      expect(response.body).toHaveProperty('user');
      adminToken = response.body.access_token;
    });

    it('/auth/login (POST) - User', async () => {
      const response = await request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'user@test.com',
          password: 'password123',
        })
        .expect(200);

      expect(response.body).toHaveProperty('access_token');
      userToken = response.body.access_token;
    });

    it('/auth/login (POST) - Invalid credentials', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'admin@test.com',
          password: 'wrongpassword',
        })
        .expect(401);
    });
  });

  describe('Users Management', () => {
    it('/users (GET) - Admin can list all users', () => {
      return request(app.getHttpServer())
        .get('/users')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body.length).toBeGreaterThan(0);
        });
    });

    it('/users (GET) - User cannot list all users', () => {
      return request(app.getHttpServer())
        .get('/users')
        .set('Authorization', `Bearer ${userToken}`)
        .expect(403);
    });

    it('/users?role=admin (GET) - Filter by role', () => {
      return request(app.getHttpServer())
        .get('/users?role=admin')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          res.body.forEach((user: any) => {
            expect(user.role).toBe('admin');
          });
        });
    });

    it('/users?sortBy=name&order=asc (GET) - Sort by name', () => {
      return request(app.getHttpServer())
        .get('/users?sortBy=name&order=asc')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          // Check if sorted by name
          for (let i = 1; i < res.body.length; i++) {
            expect(res.body[i].name >= res.body[i - 1].name).toBe(true);
          }
        });
    });

    it('/users/inactive (GET) - Get inactive users', () => {
      return request(app.getHttpServer())
        .get('/users/inactive')
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body.some((user: any) => user.email === 'inactive@test.com')).toBe(true);
        });
    });

    it('/users (POST) - Admin can create user', () => {
      return request(app.getHttpServer())
        .post('/users')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Created User',
          email: 'created@test.com',
          password: 'password123',
          role: 'user',
        })
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('name', 'Created User');
          expect(res.body).toHaveProperty('email', 'created@test.com');
        });
    });

    it('/users/:id (GET) - Admin can get user by id', () => {
      return request(app.getHttpServer())
        .get(`/users/${userId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('id', userId);
          expect(res.body).toHaveProperty('email', 'user@test.com');
        });
    });

    it('/users/profile (GET) - User can get own profile', () => {
      return request(app.getHttpServer())
        .get('/users/profile')
        .set('Authorization', `Bearer ${userToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('email', 'user@test.com');
          expect(res.body).toHaveProperty('name', 'User Test');
        });
    });

    it('/users/:id (PATCH) - User can update own profile', () => {
      return request(app.getHttpServer())
        .patch(`/users/${userId}`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          name: 'Updated User Test',
        })
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('name', 'Updated User Test');
        });
    });

    it('/users/:id (DELETE) - Admin can delete user', async () => {
      // First create a user to delete
      const userToDelete = await prisma.user.create({
        data: {
          name: 'Delete Me',
          email: 'delete@test.com',
          password: await bcrypt.hash('password123', 10),
          role: 'user',
        },
      });

      return request(app.getHttpServer())
        .delete(`/users/${userToDelete.id}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .expect(200);
    });
  });

  describe('Authorization', () => {
    it('Should require authentication', () => {
      return request(app.getHttpServer())
        .get('/users')
        .expect(401);
    });

    it('Should require admin role for user creation', () => {
      return request(app.getHttpServer())
        .post('/users')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          name: 'Unauthorized User',
          email: 'unauthorized@test.com',
          password: 'password123',
        })
        .expect(403);
    });
  });
});
