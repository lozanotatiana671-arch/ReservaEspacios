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

    // 🔹 Cargar reservas y filtrar por usuario
    ReservaDAO reservaDAO = new ReservaDAO();
    List<Reserva> todas = reservaDAO.listar();
    List<Reserva> reservas = new ArrayList<>();
    for (Reserva r : todas) {
        if (r.getUsuarioId() == usuarioId) reservas.add(r);
    }

    // 🔹 Cargar notificaciones desde el filtro
    List<Notificacion> notificaciones = (List<Notificacion>) request.getAttribute("notificaciones");
    if (notificaciones == null) notificaciones = new ArrayList<>();
    Integer notificacionesCount = (Integer) request.getAttribute("notificacionesCount");
    if (notificacionesCount == null) notificacionesCount = notificaciones.size();

    // ===== PAGINACIÓN RESERVAS =====
    int pageRes = request.getParameter("pageRes") != null ? Integer.parseInt(request.getParameter("pageRes")) : 1;
    int perPageRes = 4;
    int totalRes = reservas.size();
    int totalPagesRes = (int) Math.ceil((double) totalRes / perPageRes);
    int startRes = (pageRes - 1) * perPageRes;
    int endRes = Math.min(startRes + perPageRes, totalRes);

    // ===== PAGINACIÓN NOTIFICACIONES =====
    int pageNot = request.getParameter("pageNot") != null ? Integer.parseInt(request.getParameter("pageNot")) : 1;
    int perPageNot = 2;
    int totalNot = notificaciones.size();
    int totalPagesNot = (int) Math.ceil((double) totalNot / perPageNot);
    int startNot = (pageNot - 1) * perPageNot;
    int endNot = Math.min(startNot + perPageNot, totalNot);
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Dashboard - ReservaEspacios</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/perfilUsuario.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/contactenos.css">
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

    <!-- 🔸 Cards -->
    <div class="row mt-4">
      <div class="col-md-4 mb-4">
        <div class="card-dashboard text-center">
          <div class="mb-3"><i class="fas fa-map-marker-alt fa-2x text-primary"></i></div>
          <div class="stat-title">Tus espacios</div>
          <div class="stat-description">Consulta los espacios asignados o disponibles.</div>
        </div>
      </div>
      <div class="col-md-4 mb-4">
        <div class="card-dashboard text-center">
          <div class="mb-3"><i class="fas fa-comment-dots fa-2x text-success"></i></div>
          <div class="stat-title">Tus testimonios</div>
          <div class="stat-description">Revisa o edita tus testimonios compartidos.</div>
        </div>
      </div>
      <div class="col-md-4 mb-4">
        <div class="card-dashboard text-center">
          <div class="mb-3"><i class="fas fa-calendar-plus fa-2x text-info"></i></div>
          <div class="stat-title" href="index.jsp" >Realiza tu reserva</div>
          <div class="stat-description">Reserva un espacio en pocos clics.</div>
        </div>
      </div>
    </div>

    <!-- 🔹 Sección: Mis Reservas + Notificaciones -->
    <div class="row">
      <!-- 🔸 Mis Reservas -->
      <div class="col-md-8">
        <h5>Mis Reservas</h5>
        <div class="card-dashboard">
          <div class="table-responsive">
            <table class="table table-hover table-sm">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Recurso</th>
                  <th>Fecha</th>
                  <th>Hora</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
  <%
    if (totalRes == 0) {
  %>
    <tr><td colspan="5" class="text-center">No tienes reservas registradas</td></tr>
  <%
    } else {
      for (int i = startRes; i < endRes; i++) {
        Reserva r = reservas.get(i);
  %>
    <tr>
      <td><%= r.getId() %></td>
      <td><%= r.getRecursoId() %></td>
      <td><%= r.getFecha() %></td>
      <td><%= r.getHoraInicio() %> - <%= r.getHoraFin() %></td>
      <td><%= r.getEstado() %></td>
    </tr>
  <%
      }
    }
  %>
</tbody>

            </table>
          </div>

          <!-- 🔹 Paginación de Reservas -->
          <nav aria-label="Page navigation">
            <ul class="pagination justify-content-center">
              <% if (pageRes > 1) { %>
                <li class="page-item">
                  <a class="page-link" href="perfilUsuario.jsp?pageRes=<%= pageRes - 1 %>&pageNot=<%= pageNot %>">&lt;&lt;</a>
                </li>
              <% } %>

              <% for (int i = 1; i <= totalPagesRes; i++) { %>
                <li class="page-item <%= (i == pageRes) ? "active" : "" %>">
                  <a class="page-link" href="perfilUsuario.jsp?pageRes=<%= i %>&pageNot=<%= pageNot %>"><%= i %></a>
                </li>
              <% } %>

              <% if (pageRes < totalPagesRes) { %>
                <li class="page-item">
                  <a class="page-link" href="perfilUsuario.jsp?pageRes=<%= pageRes + 1 %>&pageNot=<%= pageNot %>">&gt;&gt;</a>
                </li>
              <% } %>
            </ul>
          </nav>
        </div>
      </div>

      <!-- 🔸 Notificaciones -->
      <div class="col-md-4">
        <h5>Notificaciones 
          <% if (notificacionesCount > 0) { %>
            <span class="badge badge-warning"><%= notificacionesCount %> nuevas</span>
          <% } %>
        </h5>
        <div class="card-dashboard">
          <%
            if (totalNot == 0) {
          %>
            <div class="notification-item text-center text-muted">No tienes notificaciones</div>
          <%
            } else {
              for (int i = startNot; i < endNot; i++) {
                Notificacion n = notificaciones.get(i);
          %>
              <div class="notification-item border-bottom pb-2 mb-2">
                <div><strong><%= n.getEstado() %></strong> - <%= n.getMensaje() %></div>
                <div class="time text-muted"><%= n.getFecha() %></div>
              </div>
          <%
              }
            }
          %>

          <!-- 🔹 Paginación Notificaciones -->
          <nav aria-label="Notificaciones navigation">
            <ul class="pagination justify-content-center">
              <% if (pageNot > 1) { %>
                <li class="page-item">
                  <a class="page-link" href="perfilUsuario.jsp?pageNot=<%= pageNot - 1 %>&pageRes=<%= pageRes %>">&lt;&lt;</a>
                </li>
              <% } %>

              <% for (int i = 1; i <= totalPagesNot; i++) { %>
                <li class="page-item <%= (i == pageNot) ? "active" : "" %>">
                  <a class="page-link" href="perfilUsuario.jsp?pageNot=<%= i %>&pageRes=<%= pageRes %>"><%= i %></a>
                </li>
              <% } %>

              <% if (pageNot < totalPagesNot) { %>
                <li class="page-item">
                  <a class="page-link" href="perfilUsuario.jsp?pageNot=<%= pageNot + 1 %>&pageRes=<%= pageRes %>">&gt;&gt;</a>
                </li>
              <% } %>
            </ul>
          </nav>

          <div class="text-center mt-3">
            <form action="NotificacionServlet" method="post">
              <input type="hidden" name="action" value="marcarTodas">
              <button type="submit" class="btn btn-sm btn-outline-success">Marcar todas como leídas</button>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Scripts -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
