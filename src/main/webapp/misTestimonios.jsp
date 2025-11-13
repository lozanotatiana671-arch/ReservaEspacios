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

    // 🔹 Cargar testimonios del usuario
    TestimonioDAO tdao = new TestimonioDAO();
    List<Testimonio> testimonios = tdao.listarPorUsuario(usuarioId);
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mis Testimonios - ReservaEspacios</title>

  <!-- Bootstrap y FontAwesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- Tus estilos -->
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
        <i class="fas fa-tachometer-alt"></i>
        <span>Dashboard</span>
      </a>
    </li>

    <li class="nav-item">
      <a class="nav-link" href="MisReservasServlet">
        <i class="fas fa-calendar-check"></i>
        <span>Mis Reservas</span>
      </a>
    </li>

    <li class="nav-item">
      <a class="nav-link active" href="TestimonioServlet?action=listar">
        <i class="fas fa-comment-dots"></i>
        <span>Mis Testimonios</span>
      </a>
    </li>

    <li class="nav-item">
      <a class="nav-link" href="notificaciones.jsp">
        <i class="fas fa-bell"></i>
        <span>Notificaciones</span>
        <% if (notificacionesCount > 0) { %>
          <span class="badge badge-warning badge-pill ml-2"><%= notificacionesCount %></span>
        <% } %>
      </a>
    </li>

    <li class="nav-item">
      <a class="nav-link" href="editarPerfil.jsp">
        <i class="fas fa-user"></i>
        <span>Mi Perfil</span>
      </a>
    </li>

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
    <h2 class="mb-0">¡Testimonios!</h2>
    <div class="user-info">
      <i class="fas fa-user"></i>
      <span>Bienvenido, <%= usuarioNombre %> 👋</span>
      <a href="LogoutServlet" class="btn btn-logout">Cerrar Sesión</a>
    </div>
  </div>

  <div class="container mt-4">
    <% if (request.getAttribute("msg") != null) { %>
      <div class="alert alert-info text-center">
        <%= request.getAttribute("msg") %>
      </div>
    <% } %>

    <% if (testimonios.isEmpty()) { %>
      <div class="alert alert-info text-center">No has publicado ningún testimonio todavía.</div>
    <% } else { %>

      <div class="card shadow-sm">
        <div class="card-header bg-success text-white">
          <h5 class="mb-0"><i class="fas fa-comments"></i> Tus testimonios publicados</h5>
        </div><br><br>

        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
              <thead class="thead-dark">
                <tr>
                  <th>ID</th>
                  <th>Recurso</th>
                  <th>Mensaje</th>
                  <th>Fecha</th>
                  <th>Estado</th>
                </tr>
              </thead>

              <tbody>
                <% for (Testimonio t : testimonios) { %>
                  <tr>
                    <td><%= t.getId() %></td>
                    <td><%= t.getTitulo() != null ? t.getTitulo() : "Sin nombre" %></td>
                    <td><%= t.getMensaje() %></td>
                    <td><%= t.getFecha() != null ? t.getFecha() : "—" %></td>

                    <td>
                      <% if ("Aprobado".equalsIgnoreCase(t.getEstado())) { %>
                        <span class="badge badge-success">Aprobado</span>
                      <% } else if ("Pendiente".equalsIgnoreCase(t.getEstado())) { %>
                        <span class="badge badge-warning text-dark">Pendiente</span>
                      <% } else { %>
                        <span class="badge badge-danger">Rechazado</span>
                      <% } %>
                    </td>
                  </tr>
                <% } %>
              </tbody>

            </table>
          </div>
        </div>

      </div>

    <% } %>
  </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
