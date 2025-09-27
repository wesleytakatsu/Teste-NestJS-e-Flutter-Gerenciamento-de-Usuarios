import { PrismaClient } from '../generated/prisma';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  // Create admin user
  const hashedPassword = await bcrypt.hash('admin123', 10);
  await prisma.user.upsert({
    where: { email: 'admin@conectar.com' },
    update: {},
    create: {
      name: 'Admin User',
      email: 'admin@conectar.com',
      password: hashedPassword,
      role: 'admin',
    },
  });
  console.log('Admin user created');

  // Create some sample users for testing
  const user1Password = await bcrypt.hash('user123', 10);
  await prisma.user.upsert({
    where: { email: 'user1@exemplo.com' },
    update: {},
    create: {
      name: 'João Silva',
      email: 'user1@exemplo.com',
      password: user1Password,
      role: 'user',
      lastLogin: new Date(Date.now() - 45 * 24 * 60 * 60 * 1000), // 45 days ago (inactive)
    },
  });

  const user2Password = await bcrypt.hash('user123', 10);
  await prisma.user.upsert({
    where: { email: 'user2@exemplo.com' },
    update: {},
    create: {
      name: 'Maria Santos',
      email: 'user2@exemplo.com',
      password: user2Password,
      role: 'user',
      lastLogin: new Date(), // Active user
    },
  });

  const user3Password = await bcrypt.hash('user123', 10);
  await prisma.user.upsert({
    where: { email: 'admin2@exemplo.com' },
    update: {},
    create: {
      name: 'Carlos Admin',
      email: 'admin2@exemplo.com',
      password: user3Password,
      role: 'admin',
      lastLogin: null, // Never logged in (inactive)
    },
  });

  console.log('Sample users created for testing');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });