<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.reservas.Usuario" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    // Sesión del administrador
    HttpSession sesion = request.getSession(false);
    String adminNombre = (sesion != null) ? (String) sesion.getAttribute("usuarioNombre") : "Admin";
%>

<%
    Usuario usuario = (Usuario) request.getAttribute("usuario");
    boolean esEditar = (usuario != null);
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= esEditar ? "Editar Usuario" : "Nuevo Usuario" %></title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link href="https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Tus estilos -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/reservas.css">
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
            👤 <%= adminNombre %>
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
        <div class="auf-wrapper">
          <div class="auf-container">
            <div class="auf-header">
              <h1 id="tituloFormulario">
                <i class="bi bi-person-plus"></i>
                <%= esEditar ? "Editar Usuario" : "Nuevo Usuario" %>
              </h1>
            </div>

            <div class="auf-card">
              <form id="formUsuario" action="<%= request.getContextPath() %>/UsuarioServlet" method="post" autocomplete="off" autocapitalize="off" spellcheck="false">
    <% if (esEditar) { %>
        <input type="hidden" name="id" value="<%= usuario.getId() %>">
        <input type="hidden" name="action" value="actualizar">
    <% } else { %>
        <input type="hidden" name="action" value="insertar">
    <% } %>

    <div class="auf-group">
        <label for="nombre">Nombre completo</label>
        <input type="text" id="nombre" name="nombre" class="auf-input"
               value="<%= esEditar ? usuario.getNombre() : "" %>"
               placeholder="Ej: Juan Pérez" required autocomplete="off">
    </div>

    <div class="auf-group">
        <label for="identificacion">Identificación</label>
        <input type="text" id="identificacion" name="identificacion" class="auf-input"
               value="<%= esEditar ? usuario.getIdentificacion() : "" %>"
               placeholder="Ej: 123456789" required autocomplete="off">
    </div>

    <div class="auf-group">
        <label for="correo">Correo electrónico</label>
        <input type="email" id="correo" name="correo" class="auf-input"
               value="<%= esEditar ? usuario.getCorreo() : "" %>"
               placeholder="usuario@ejemplo.com" required autocomplete="off">
    </div>

    <!-- Teléfono y Rol -->
    <div class="row">
        <div class="col-md-6">
            <div class="auf-group">
                <label for="telefono">Teléfono</label>
                <input type="text" id="telefono" name="telefono" class="auf-input"
                       value="<%= esEditar ? usuario.getTelefono() : "" %>"
                       placeholder="Ej: 3001234567" required autocomplete="off">
            </div>
        </div>

        <div class="col-md-6">
            <div class="auf-group">
                <label for="rol">Rol</label>
                <div class="auf-select-wrapper">
                    <select id="rol" name="rol" class="auf-select" required autocomplete="off">
                        <option value="USUARIO" <%= esEditar && "USUARIO".equals(usuario.getRol()) ? "selected" : "" %>>Usuario</option>
                        <option value="ADMIN" <%= esEditar && "ADMIN".equals(usuario.getRol()) ? "selected" : "" %>>Administrador</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <% if (!esEditar) { %>
    <div class="auf-group" id="campoPassword">
        <label for="password">Contraseña</label>
        <input type="password" id="password" name="password" class="auf-input"
               required autocomplete="new-password">
    </div>
    <% } %>

    <div class="auf-actions">
        <button type="submit" class="auf-btn auf-btn-primary">
            <i class="bi bi-check-circle"></i>
            <%= esEditar ? "Actualizar" : "Registrar" %>
        </button>

        <a href="<%= request.getContextPath() %>/UsuarioServlet?action=listar" class="auf-btn auf-btn-secondary">
            <i class="bi bi-x-circle"></i> Cancelar
        </a>
    </div>
</form>

            </div>
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
        menuToggle.addEventListener('click', () => sideMenu.classList.toggle('active'));
        document.addEventListener('click', (event) => {
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
