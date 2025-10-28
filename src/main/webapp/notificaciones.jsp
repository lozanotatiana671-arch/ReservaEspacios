<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession, java.util.*, com.reservas.*" %>
<%
    // 🔹 Verificar sesión
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int usuarioId = (int) sesion.getAttribute("usuarioId");
    String usuarioNombre = (String) sesion.getAttribute("usuarioNombre");

    // 🔹 Cargar notificaciones desde el filtro
    List<Notificacion> notificaciones = (List<Notificacion>) request.getAttribute("notificaciones");
    if (notificaciones == null) notificaciones = new ArrayList<>();
    Integer notificacionesCount = (Integer) request.getAttribute("notificacionesCount");
    if (notificacionesCount == null) notificacionesCount = notificaciones.size();

    // 🔹 Parámetros de paginación
    int paginaActual = 1;
    int perPage = 2;
    if (request.getParameter("page") != null) {
        try { paginaActual = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {}
    }
    int total = notificaciones.size();
    int totalPages = (int) Math.ceil((double) total / perPage);
    int start = (paginaActual - 1) * perPage;
    int end = Math.min(start + perPage, total);

%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Notificaciones - ReservaEspacios</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Estilos personalizados -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/perfilUsuario.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/notificaciones.css">
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
      <h2 class="mb-0">¡Bienvenido!</h2>
      <div class="user-info">
        <i class="fas fa-user"></i>
        <span>Bienvenido, <%= usuarioNombre %> 👋</span>
        <a href="LogoutServlet" class="btn btn-logout">Cerrar Sesión</a>
      </div>
    </div>
    <br><br><br>

    <!-- ✅ SECCIÓN DE NOTIFICACIONES -->
    <div class="noti-wrapper">
      <div class="noti-header">
        <h2><i class="fas fa-bell"></i> Notificaciones</h2>
        <% if (notificacionesCount > 0) { %>
          <form action="NotificacionServlet" method="post">
            <input type="hidden" name="action" value="marcarTodas">
            <button type="submit" class="btn-n-markall">
              <i class="fas fa-check-double"></i> Marcar todas como leídas
            </button>
          </form>
        <% } %>
      </div>

      <% if (notificaciones.isEmpty()) { %>
        <div class="noti-empty">
          <p><i class="fas fa-inbox"></i> No tienes notificaciones por el momento.</p>
        </div>
      <% } else { 
          for (int i = start; i < end; i++) {
              Notificacion n = notificaciones.get(i);
              String msg = (n.getMensaje() != null ? n.getMensaje() : "Notificación sin contenido");
              String clase = "ok"; String icono = "fa-circle-check"; String color = "#007B3E";
              String low = msg.toLowerCase();
              if (low.contains("rechaz") || low.contains("no disponible") || low.contains("error")) {
                  clase = "error"; icono = "fa-circle-xmark"; color = "#D9534F";
              } else if (low.contains("activa") || low.contains("recordatorio") || low.contains("pendiente")) {
                  clase = "aviso"; icono = "fa-circle-exclamation"; color = "#FBE122";
              }
      %>
        <div class="noti-card <%= clase %>">
          <div class="noti-icon" style="color:<%= color %>;">
            <i class="fa-solid <%= icono %>"></i>
          </div>
          <div class="noti-text"><%= msg %></div>
          <% if ("NUEVA".equalsIgnoreCase(n.getEstado())) { %>
            <form action="NotificacionServlet" method="post" class="ml-auto">
              <input type="hidden" name="action" value="marcarLeida">
              <input type="hidden" name="id" value="<%= n.getId() %>">
              <button type="submit" class="btn-n-read">
                <i class="fas fa-check"></i> Leída
              </button>
            </form>
          <% } %>
        </div>
      <% } %>

      <!-- 🔹 Paginación -->
<% if (totalPages > 1) { %>
  <nav class="mt-4">
    <ul class="pagination justify-content-center">
      <li class="page-item <%= (paginaActual <= 1 ? "disabled" : "") %>">
        <a class="page-link" href="notificaciones.jsp?page=<%= paginaActual - 1 %>">&laquo; Anterior</a>
      </li>
      <% for (int p = 1; p <= totalPages; p++) { %>
        <li class="page-item <%= (p == paginaActual ? "active" : "") %>">
          <a class="page-link" href="notificaciones.jsp?page=<%= p %>"><%= p %></a>
        </li>
      <% } %>
      <li class="page-item <%= (paginaActual >= totalPages ? "disabled" : "") %>">
        <a class="page-link" href="notificaciones.jsp?page=<%= paginaActual + 1 %>">Siguiente &raquo;</a>
      </li>
    </ul>
  </nav>
<% } %>

      <% } %>
    </div>
    <!-- 🟢 FIN SECCIÓN NOTIFICACIONES -->
  </div>

  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
