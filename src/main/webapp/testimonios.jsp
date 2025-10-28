<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*, com.reservas.Testimonio" %>

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
        <h2><i class="bi bi-chat-quote"></i> Gestionar Testimonios</h2>

        <div class="table-section">
          <table class="table mb-0">
            <thead>
              <tr>
                <th>ID</th>
                <th>Usuario</th>
                <th>Mensaje</th>
                <th>Estado</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <%
                List<Testimonio> testimonios = (List<Testimonio>) request.getAttribute("testimonios");
                if (testimonios != null && !testimonios.isEmpty()) {
                    for (Testimonio t : testimonios) {
              %>
              <tr>
                <td><%= t.getId() %></td>
                <td><%= t.getUsuarioNombre() %></td>
                <td class="text-left"><%= t.getMensaje() %></td>
                <td>
                  <% if ("Pendiente".equalsIgnoreCase(t.getEstado())) { %>
                    <span class="badge-pendiente"><i class="bi bi-clock"></i> Pendiente</span>
                  <% } else if ("Aprobado".equalsIgnoreCase(t.getEstado())) { %>
                    <span class="badge-aprobado"><i class="bi bi-check-circle"></i> Aprobado</span>
                  <% } else if ("Rechazado".equalsIgnoreCase(t.getEstado())) { %>
                    <span class="badge-rechazado"><i class="bi bi-x-circle"></i> Rechazado</span>
                  <% } else { %>
                    <span class="badge badge-secondary"><%= t.getEstado() %></span>
                  <% } %>
                </td>
                <td><%= t.getFecha() %></td>
                <td>
                  <a href="CambiarEstadoTestimonioServlet?id=<%= t.getId() %>&estado=Aprobado" class="btn-action btn-aprobar">
                    <i class="bi bi-check-lg"></i> Aprobar
                  </a>
                  <a href="CambiarEstadoTestimonioServlet?id=<%= t.getId() %>&estado=Rechazado" class="btn-action btn-rechazar">
                    <i class="bi bi-x-lg"></i> Rechazar
                  </a>
                  <a href="EliminarTestimonioServlet?id=<%= t.getId() %>" class="btn-action btn-eliminar"
                     onclick="return confirm('¿Eliminar este testimonio?');">
                    <i class="bi bi-trash"></i> Eliminar
                  </a>
                </td>
              </tr>
              <%
                    }
                } else {
              %>
              <tr>
                <td colspan="6" class="empty-row text-center py-3">
                  <i class="bi bi-inbox"></i> No hay testimonios registrados
                </td>
              </tr>
              <%
                }
              %>
            </tbody>
          </table>
        </div>
      </main>
    </div>
  </div>

  <script>
    function previewImage(input) {
      const preview = document.getElementById('imgPreview');
      if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function (e) {
          preview.src = e.target.result;
          preview.style.display = 'block';
        };
        reader.readAsDataURL(input.files[0]);
      }
    }
  </script>

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
