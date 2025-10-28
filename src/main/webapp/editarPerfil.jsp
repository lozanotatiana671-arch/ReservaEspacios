<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession, java.util.*, com.reservas.*" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int usuarioId = (Integer) sesion.getAttribute("usuarioId");
    String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");
    String correo = (String) sesion.getAttribute("usuarioCorreo");
    String telefono = (String) sesion.getAttribute("usuarioTelefono");

    // 🔹 Cargar notificaciones desde el filtro
    List<Notificacion> notificaciones = (List<Notificacion>) request.getAttribute("notificaciones");
    if (notificaciones == null) notificaciones = new ArrayList<>();
    Integer notificacionesCount = (Integer) request.getAttribute("notificacionesCount");
    if (notificacionesCount == null) notificacionesCount = notificaciones.size();
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Editar Perfil - ReservaEspacios</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Estilos personalizados -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/perfilUsuario.css">
</head>

<body>
  <!-- 🔹 Sidebar -->
<div class="sidebar">
  <a class="navbar-brand" href="index.jsp">ReservaEspacios</a>
  <ul class="nav flex-column mt-4">

    <!-- Dashboard -->
    <li class="nav-item">
      <a class="nav-link" href="perfilUsuario.jsp">
        <i class="fas fa-tachometer-alt"></i>
        <span>Dashboard</span>
      </a>
    </li>

    <!-- Mis Reservas -->
    <li class="nav-item">
      <a class="nav-link" href="MisReservasServlet">
        <i class="fas fa-calendar-check"></i>
        <span>Mis Reservas</span>
      </a>
    </li>

    <!-- Mis Testimonios -->
    <li class="nav-item">
      <a class="nav-link" href="misTestimonios.jsp">
        <i class="fas fa-comment-dots"></i>
        <span>Mis Testimonios</span>
      </a>
    </li>

    <!-- Notificaciones -->
    <li class="nav-item">
      <a class="nav-link" href="notificaciones.jsp">
        <i class="fas fa-bell"></i>
        <span>Notificaciones</span>
        <% if (notificacionesCount > 0) { %>
          <span class="badge badge-warning badge-pill ml-2"><%= notificacionesCount %></span>
        <% } %>
      </a>
    </li>

    <!-- Mi Perfil -->
    <li class="nav-item">
      <a class="nav-link" href="editarPerfil.jsp">
        <i class="fas fa-user"></i>
        <span>Mi Perfil</span>
      </a>
    </li>

    <!-- Contáctenos -->
    <li class="nav-item">
      <a class="nav-link" href="contactenos.jsp">
        <i class="fas fa-envelope"></i>
        <span>Contáctenos</span>
      </a>
    </li>
  </ul>
</div>


  <!-- 🔹 Contenido Principal -->
  <div class="content">
    <div class="header">
      <h2 class="mb-0">Editar Perfil</h2>
      <div class="user-info">
        <i class="fas fa-user"></i>
        <span>Bienvenido, <%= usuarioNombre %> 👋</span>
        <a href="LogoutServlet" class="btn btn-logout">Cerrar Sesión</a>
      </div>
    </div>

    <!-- 🔹 Formulario -->
    <div class="container mt-4">
     <form action="EditarPerfilServlet" method="post" class="formularioEditarPerfilUsuario">
  <h3 class="tituloEditarPerfil">Editar Perfil</h3>

  <input type="hidden" name="id" value="<%= usuarioId %>">

  <div class="grupoEditarPerfil">
    <label for="nombre">Nombre completo</label>
    <input type="text" id="nombre" name="nombre" class="inputEditarPerfil"
           value="<%= usuarioNombre %>" required autocomplete="off">
  </div>

  <div class="grupoEditarPerfil">
    <label for="correo">Correo electrónico</label>
    <input type="email" id="correo" name="correo" class="inputEditarPerfil"
           value="<%= correo %>" required autocomplete="off">
  </div>

  <div class="grupoEditarPerfil">
    <label for="telefono">Teléfono</label>
    <input type="text" id="telefono" name="telefono" class="inputEditarPerfil"
           value="<%= telefono %>" required autocomplete="off">
  </div>

  <div class="grupoEditarPerfil">
    <label for="password">Nueva contraseña</label>
    <input type="password" id="password" name="password" class="inputEditarPerfil"
           placeholder="Dejar en blanco si no cambia" autocomplete="off">
  </div>

  <button type="submit" class="btnEditarPerfilGuardar">Guardar Cambios</button>
  <a href="perfilUsuario.jsp" class="btnEditarPerfilCancelar">Cancelar</a>

  <p class="mensajeEditarPerfil">
    <%= request.getAttribute("mensaje") != null ? request.getAttribute("mensaje") : "" %>
  </p>
</form>

    </div>
  </div>
</body>
</html>
