import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async create(createUserDto: CreateUserDto) {
    // Check if email already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email: createUserDto.email },
    });
    if (existingUser) {
      throw new Error('Email already exists');
    }

    // Hash password if provided
    if (createUserDto.password) {
      const bcrypt = require('bcrypt');
      createUserDto.password = await bcrypt.hash(createUserDto.password, 10);
    }

    return this.prisma.user.create({ data: createUserDto });
  }

  async findAll(query: any) {
    const { role, sortBy, order, name } = query;
    const where: any = {};
    if (role) where.role = role;
    if (name) where.name = { contains: name };

    const orderBy: any = {};
    if (sortBy) {
      orderBy[sortBy] = order === 'desc' ? 'desc' : 'asc';
    }

    return this.prisma.user.findMany({ where, orderBy });
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto) {
    return this.prisma.user.update({ where: { id }, data: updateUserDto });
  }

  async remove(id: string) {
    return this.prisma.user.delete({ where: { id } });
  }

  async findInactiveUsers() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    return this.prisma.user.findMany({
      where: {
        OR: [
          { lastLogin: null },
          { lastLogin: { lt: thirtyDaysAgo } },
        ],
      },
    });
  }
}
