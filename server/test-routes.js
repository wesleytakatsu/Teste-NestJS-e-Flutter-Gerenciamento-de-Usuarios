const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testRoutes() {
  let adminToken = '';
  let userToken = '';
  let userId = '';

  console.log('🚀 Testando rotas da API Conectar...\n');

  try {
    // 1. Teste de registro - usar email único
    console.log('1. Testando registro de usuário...');
    const timestamp = Date.now();
    const registerResponse = await axios.post(`${BASE_URL}/auth/register`, {
      name: 'Test User',
      email: `testuser${timestamp}@example.com`,
      password: 'password123',
      role: 'user'
    });
    console.log('✅ Registro realizado com sucesso:', registerResponse.data);
    userId = registerResponse.data.id;

    // 2. Login do admin
    console.log('\n2. Testando login do admin...');
    const adminLogin = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'admin@conectar.com',
      password: 'admin123'
    });
    console.log('✅ Login admin realizado com sucesso');
    console.log('Token:', adminLogin.data.access_token.substring(0, 50) + '...');
    adminToken = adminLogin.data.access_token;

    // 3. Login do usuário
    console.log('\n3. Testando login do usuário...');
    const userLogin = await axios.post(`${BASE_URL}/auth/login`, {
      email: 'user1@exemplo.com',
      password: 'user123'
    });
    console.log('✅ Login usuário realizado com sucesso');
    userToken = userLogin.data.access_token;

    // 4. Listar todos os usuários (admin)
    console.log('\n4. Testando listagem de usuários (admin)...');
    const users = await axios.get(`${BASE_URL}/users`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✅ Listagem de usuários:', users.data.length, 'usuários encontrados');

    // 5. Filtrar usuários por role
    console.log('\n5. Testando filtro por role...');
    const adminUsers = await axios.get(`${BASE_URL}/users?role=admin`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✅ Filtro por role:', adminUsers.data.length, 'admins encontrados');

    // 6. Usuários inativos
    console.log('\n6. Testando busca de usuários inativos...');
    const inactiveUsers = await axios.get(`${BASE_URL}/users/inactive`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✅ Usuários inativos:', inactiveUsers.data.length, 'usuários inativos');

    // 7. Perfil do usuário
    console.log('\n7. Testando perfil do usuário...');
    const profile = await axios.get(`${BASE_URL}/users/profile`, {
      headers: { Authorization: `Bearer ${userToken}` }
    });
    console.log('✅ Perfil do usuário:', profile.data.name);

    // 8. Criar usuário (admin)
    console.log('\n8. Testando criação de usuário (admin)...');
    const newUser = await axios.post(`${BASE_URL}/users`, {
      name: 'Novo Usuário',
      email: 'novo@example.com',
      password: 'password123',
      role: 'user'
    }, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✅ Usuário criado:', newUser.data.name);

    // 9. Buscar usuário por ID (admin)
    console.log('\n9. Testando busca por ID...');
    const userById = await axios.get(`${BASE_URL}/users/${newUser.data.id}`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✅ Usuário encontrado:', userById.data.name);

    // 10. Atualizar usuário
    console.log('\n10. Testando atualização de usuário...');
    const updatedUser = await axios.patch(`${BASE_URL}/users/${newUser.data.id}`, {
      name: 'Usuário Atualizado'
    }, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✅ Usuário atualizado:', updatedUser.data.name);

    // 11. Deletar usuário (admin)
    console.log('\n11. Testando exclusão de usuário...');
    await axios.delete(`${BASE_URL}/users/${newUser.data.id}`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✅ Usuário deletado com sucesso');

    console.log('\n🎉 Todos os testes passaram! API funcionando corretamente.');

  } catch (error) {
    console.error('❌ Erro no teste:', error.response?.data || error.message);
    if (error.response?.status) {
      console.error('Status:', error.response.status);
    }
  }
}

// Executar testes se chamado diretamente
if (require.main === module) {
  testRoutes();
}

module.exports = { testRoutes };