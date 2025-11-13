<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession, java.util.*, com.reservas.Notificacion" %>

<%
    // 🔹 Validar sesión de usuario
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");
    String usuarioCorreo = (String) sesion.getAttribute("usuarioCorreo");

    // 🔹 Cargar notificaciones (para que el menú funcione sin error)
    List<Notificacion> notificaciones = (List<Notificacion>) request.getAttribute("notificaciones");
    if (notificaciones == null) notificaciones = new ArrayList<>();

    Integer notificacionesCount = (Integer) request.getAttribute("notificacionesCount");
    if (notificacionesCount == null) notificacionesCount = notificaciones.size();
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contáctenos - ReservaEspacios</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Estilos personalizados -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/perfilUsuario.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/contactenos.css">
</head>

<body>
  <!-- 🔹 Sidebar -->
  <div class="sidebar">
    <a class="navbar-brand" href="index.jsp">ReservaEspacios</a>
    <ul class="nav flex-column mt-4">

      <li class="nav-item">
        <a class="nav-link" href="perfilUsuario.jsp">
          <i class="fas fa-tachometer-alt"></i> <span>Dashboard</span>
        </a>
      </li>

      <li class="nav-item">
        <a class="nav-link" href="MisReservasServlet">
          <i class="fas fa-calendar-check"></i> <span>Mis Reservas</span>
        </a>
      </li>

      <li class="nav-item">
        <a class="nav-link" href="misTestimonios.jsp">
          <i class="fas fa-comment-dots"></i> <span>Mis Testimonios</span>
        </a>
      </li>

      <li class="nav-item">
        <a class="nav-link" href="notificaciones.jsp">
          <i class="fas fa-bell"></i> <span>Notificaciones</span>
          <% if (notificacionesCount > 0) { %>
            <span class="badge badge-warning badge-pill ml-2"><%= notificacionesCount %></span>
          <% } %>
        </a>
      </li>

      <li class="nav-item">
        <a class="nav-link" href="editarPerfil.jsp">
          <i class="fas fa-user"></i> <span>Mi Perfil</span>
        </a>
      </li>

      <li class="nav-item">
        <a class="nav-link active" href="contactenos.jsp">
          <i class="fas fa-envelope"></i> <span>Contáctenos</span>
        </a>
      </li>
    </ul>
  </div>

  <!-- 🔹 Contenido Principal -->
  <div class="content">
    <div class="header">
      <h2 class="mb-0">Contáctenos</h2>
      <div class="user-info">
        <i class="fas fa-user"></i>
        <span>Bienvenido, <%= usuarioNombre %> 👋</span>
        <a href="LogoutServlet" class="btn btn-logout">Cerrar Sesión</a>
      </div>
    </div>

    <!-- 🔸 Formulario de Contacto -->
    <div class="contact-container">
      <h2 class="contact-title"><i class="fas fa-headset"></i> Escríbenos</h2>
      <p class="contact-subtitle">
        Si tienes dudas, sugerencias o inconvenientes con tus reservas, no dudes en escribirnos.  
        ¡Estamos para ayudarte! 💬
      </p>

      <form action="ContactenosServlet" method="post" class="contact-form">

        <!-- 🔥 Campo oculto con el ID del usuario autenticado -->
        <input type="hidden" name="usuarioId" value="<%= sesion.getAttribute("usuarioId") %>">

        <div class="form-group">
          <label for="nombre"><i class="fas fa-user"></i> Nombre completo</label>
          <input type="text" class="form-control" id="nombre" name="nombre"
                 value="<%= usuarioNombre %>" readonly>
        </div>

        <div class="form-group">
          <label for="correo"><i class="fas fa-envelope"></i> Correo electrónico</label>
          <input type="email" class="form-control" id="correo" name="correo"
                 value="<%= usuarioCorreo %>" readonly>
        </div>

        <div class="form-group">
          <label for="mensaje"><i class="fas fa-comment"></i> Mensaje</label>
          <textarea class="form-control" id="mensaje" name="mensaje" rows="5"
                    placeholder="Escribe tu mensaje aquí..." required></textarea>
        </div>

        <button type="submit" class="btn-enviar">
          <i class="fas fa-paper-plane"></i> Enviar Mensaje
        </button>
      </form>

      <% if (request.getAttribute("mensaje") != null) { %>
        <div class="alert alert-success mt-3 text-center">
          <%= request.getAttribute("mensaje") %>
        </div>
      <% } %>
    </div>
  </div>

  <!-- Bootstrap JS -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
