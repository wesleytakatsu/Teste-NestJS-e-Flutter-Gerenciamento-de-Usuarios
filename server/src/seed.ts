import { PrismaClient } from '../generated/prisma';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
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
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });