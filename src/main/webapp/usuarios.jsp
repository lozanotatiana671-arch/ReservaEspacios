<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*, com.reservas.Usuario" %>

<%
    // Sesión del administrador
    HttpSession sesion = request.getSession(false);
    String adminNombre = (sesion != null) ? (String) sesion.getAttribute("usuarioNombre") : "Admin";
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel de Administrador</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
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
            <li class="nav-item">
                <a class="nav-link" href="ListaReservasServlet">📋 Reservas</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="ListaRecursosServlet">⚙️ Recursos</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="UsuarioServlet?action=listar">👤 Usuarios</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="ReporteServlet">📊 Reportes</a>
            </li>
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

        <h2>👥 Lista de Usuarios</h2>

  <div class="mb-4">
    <a href="UsuarioServlet?action=nuevo" class="btn btn-primary">➕ Nuevo Usuario</a>
  </div>
      
<!-- 🔍 Buscador de usuarios -->
<div class="uno-buscador">
  <form action="UsuarioServlet" method="get" class="dos-formulario" autocomplete="off">
    <input type="hidden" name="action" value="buscar">
    <input 
      type="text" 
      name="criterio" 
      class="tres-campo" 
      placeholder="Buscar por nombre o documento"
      value="<%= request.getAttribute("criterio") != null ? request.getAttribute("criterio") : "" %>">
    <button type="submit" class="cuatro-boton">
      <i class="fas fa-search"></i> Buscar
    </button>
    <a href="UsuarioServlet?action=listar" class="cinco-restablecer">
      <i class="fas fa-undo"></i> Restablecer
    </a>
  </form>
</div>


  <table class="table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Nombre</th>
        <th>Identificación</th>
        <th>Correo</th>
        <th>Teléfono</th>
        <th>Rol</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody>
      <%
        List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
        if (usuarios != null && !usuarios.isEmpty()) {
            for (Usuario u : usuarios) {
      %>
      <tr>
        <td><%= u.getId() %></td>
        <td><%= u.getNombre() %></td>
        <td><%= u.getIdentificacion() %></td>
        <td><%= u.getCorreo() %></td>
        <td><%= u.getTelefono() %></td>
        <td><%= u.getRol() %></td>
        <td>
          <a href="UsuarioServlet?action=editar&id=<%= u.getId() %>" class="btn btn-warning">✏️ Editar</a>
          <a href="UsuarioServlet?action=eliminar&id=<%= u.getId() %>" class="btn btn-danger"
             onclick="return confirm('¿Seguro que deseas eliminar este usuario?')">🗑️ Eliminar</a>
        </td>
      </tr>
      <%
            }
        } else {
      %>
      <tr>
        <td colspan="7" class="text-center">No hay usuarios registrados</td>
      </tr>
      <%
        }
      %>
    </tbody>
  </table>
      
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
