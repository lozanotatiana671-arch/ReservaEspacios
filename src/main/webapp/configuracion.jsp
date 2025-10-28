<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    // Control de sesión y verificación de rol
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String rol = (String) sesion.getAttribute("usuarioRol");
    if (!"admin".equalsIgnoreCase(rol)) {
        response.sendRedirect("perfilUsuario.jsp");
        return;
    }

    // Datos del administrador
    int adminId = (Integer) sesion.getAttribute("usuarioId");
    String nombre = (String) sesion.getAttribute("usuarioNombre");
    String correo = (String) sesion.getAttribute("usuarioCorreo");
    String telefono = (String) sesion.getAttribute("usuarioTelefono");
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel de Administrador</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>

<body>
    <!-- 🔹 Navbar para administrador -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <a class="navbar-brand" href="ListaReservasServlet">SistemaReserva</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" 
            data-target="#navbarNav" aria-controls="navbarNav" 
            aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item"><a class="nav-link" href="ListaReservasServlet">📋 Reservas</a></li>
            <li class="nav-item"><a class="nav-link" href="ListaRecursosServlet">⚙️ Recursos</a></li>
            <li class="nav-item"><a class="nav-link" href="UsuarioServlet?action=listar">👤 Usuarios</a></li>
            <li class="nav-item"><a class="nav-link" href="ReporteServlet">📊 Reportes</a></li>
        </ul>

        <span class="navbar-text text-white mr-3">
            👤 <%= nombre %>
        </span>
        <a href="LogoutServlet" class="btn btn-logout btn-sm btn-outline-light">Cerrar Sesión</a>
    </div>
  </nav>

<!-- Botón menú móvil -->
<button class="menu-toggle" id="menuToggle">
  <i class="fas fa-bars"></i>
</button>

<div class="container-fluid">
  <div class="row" style="margin-right: -20px;">

    <!-- Menú lateral -->
    <nav class="col-md-2 side-menu" style="margin-right: -20px;" id="sideMenu">
      <h4><i class="fas fa-cogs"></i> Administración</h4>
      <a href="UsuarioServlet?action=listar"><i class="fas fa-users"></i> Usuarios</a>
      <a href="configuracion.jsp"><i class="fas fa-cog"></i> Configuración</a>
      <a href="BannerServlet"><i class="fas fa-image"></i> Banner</a>
      <hr>
      <a href="ListaReservasServlet"><i class="fas fa-calendar-check"></i> Gestionar Reservas</a>
      <a href="TestimonioServlet?action=listar"><i class="fas fa-comment-alt"></i> Gestionar Testimonios</a>
      <a href="ListaConsultasServlet?action=listar"><i class="fas fa-envelope"></i> Gestionar Consultas</a>
      <hr>
      <a href="nuevoRecurso.jsp"><i class="fas fa-plus-circle"></i> Nuevo Espacio</a>
      <a href="ListaRecursosServlet?action=listar"><i class="fas fa-building"></i> Gestionar Espacios</a>
      <a href="ReporteServlet"><i class="fas fa-chart-bar"></i> Reportes</a>
    </nav>

    <!-- Contenido principal -->
    <main class="col-md-10 content-area">

      <div class="main-wrapper">
        <div class="profile-card">
          <h2><i class="bi bi-person-gear"></i> Editar Perfil Administrador</h2>

          <form action="EditarPerfilServlet" method="post">
            <input type="hidden" name="id" value="<%= adminId %>">

            <div class="form-group">
              <label for="nombre">Nombre completo</label>
              <input type="text" class="form-control" id="nombre" name="nombre" value="<%= nombre %>" required>
            </div>

            <div class="form-group">
              <label for="correo">Correo electrónico</label>
              <input type="email" class="form-control" id="correo" name="correo" value="<%= correo %>" required>
            </div>

            <div class="form-group">
              <label for="telefono">Teléfono</label>
              <input type="text" class="form-control" id="telefono" name="telefono" value="<%= telefono %>" required>
            </div>

            <div class="form-group">
              <label for="password">Nueva contraseña</label>
              <input type="password" class="form-control" id="password" name="password" placeholder="Dejar en blanco si no cambia">
            </div>

            <div class="btn-group-actions">
              <button type="submit" class="btn-custom">Guardar cambios</button>
              <a href="ListaReservasServlet" class="btn-custom">Cancelar</a>
            </div>
          </form>

          <!-- Mensaje del servlet -->
          <p class="text-center mt-3 text-danger">
            <%= request.getAttribute("mensaje") != null ? request.getAttribute("mensaje") : "" %>
          </p>
        </div>
      </div>

    </main>
  </div>
</div>

<!-- Script menú móvil -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.getElementById('menuToggle');
    const sideMenu = document.getElementById('sideMenu');
    
    if (menuToggle && sideMenu) {
      menuToggle.addEventListener('click', function() {
        sideMenu.classList.toggle('active');
      });
      
      document.addEventListener('click', function(event) {
        if (window.innerWidth <= 767) {
          const isClickInside = sideMenu.contains(event.target) || menuToggle.contains(event.target);
          if (!isClickInside && sideMenu.classList.contains('active')) {
            sideMenu.classList.remove('active');
          }
        }
      });
    }
  });
</script>

</body>
</html>
