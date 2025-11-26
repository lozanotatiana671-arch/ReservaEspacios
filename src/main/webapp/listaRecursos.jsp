<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<%
    // Sesión del administrador
    HttpSession sesion = request.getSession(false);
    String adminNombre = (sesion != null) ? (String) sesion.getAttribute("usuarioNombre") : "Admin";
%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

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
            <li class="nav-item"><a class="nav-link" href="ListaRecursosServlet?action=listar">⚙️ Recursos</a></li>
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

        <h2>⚙️ Gestión de Recursos</h2>
        <a href="nuevoRecurso.jsp" class="btn btn-nuevo mb-3">➕ Nuevo Recurso</a>

        <table class="table table-custom text-center align-middle">
          <thead>
            <tr>
              <th>ID</th>
              <th>Imagen</th>
              <th>Nombre</th>
              <th>Tipo</th>
              <th>Ubicación</th>
              <th>Capacidad</th>
              <th>Tarifa</th>
              <th>Estado</th>
              <th>Disponible</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${not empty recursos}">
                <c:forEach var="r" items="${recursos}">
                  <tr>
                    <td>${r.id}</td>
                    <td>
  <c:choose>
    <!-- Si hay imagen -->
    <c:when test="${not empty r.imagen}">
      <c:choose>
        <!-- Si es URL completa (GitHub u otra) -->
        <c:when test="${fn:startsWith(r.imagen, 'http')}">
          <img src="${r.imagen}"
               alt="Imagen de ${r.nombre}" width="70" height="50" class="rounded">
        </c:when>

        <!-- Si es ruta interna del proyecto (compatibilidad con lo viejo) -->
        <c:otherwise>
          <img src="${pageContext.request.contextPath}/${r.imagen}"
               alt="Imagen de ${r.nombre}" width="70" height="50" class="rounded">
        </c:otherwise>
      </c:choose>
    </c:when>

    <!-- Si NO hay imagen, usar la por defecto -->
    <c:otherwise>
      <img src="${pageContext.request.contextPath}/img/default-space.jpg"
           alt="Imagen de ${r.nombre}" width="70" height="50" class="rounded">
    </c:otherwise>
  </c:choose>
</td>

                    <td>${r.nombre}</td>
                    <td>${r.tipo}</td>
                    <td>
                      <c:choose>
                        <c:when test="${not empty r.ubicacion}">
                          ${r.ubicacion}
                        </c:when>
                        <c:otherwise>Sin ubicación</c:otherwise>
                      </c:choose>
                    </td>
                    <td>${r.capacidad}</td>
                    <td>$ ${r.tarifa}</td>
                    <td>
                      <c:choose>
    <c:when test="${fn:toUpperCase(r.estado) eq 'DISPONIBLE'}">
        <span class="badge badge-disponible">Disponible</span>
    </c:when>

    <c:when test="${fn:toUpperCase(r.estado) eq 'EN MANTENIMIENTO'}">
        <span class="badge badge-mantenimiento">En Mantenimiento</span>
    </c:when>

    <c:otherwise>
        <span class="badge badge-nodisponible">No Disponible</span>
    </c:otherwise>
</c:choose>

                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.disponible}">
                          <span class="badge badge-disponible">Sí</span>
                        </c:when>
                        <c:otherwise>
                          <span class="badge badge-no-disponible">No</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="acciones-celda">
                      <a href="editarRecurso.jsp?id=${r.id}" class="btn btn-editar btn-sm">✏️ Editar</a>
                      <a href="EliminarRecursoServlet?id=${r.id}"
                         class="btn btn-eliminar btn-sm"
                         onclick="return confirm('¿Seguro que deseas eliminar este recurso?');">🗑️ Eliminar</a>
                    </td>
                  </tr>
                </c:forEach>
              </c:when>
              <c:otherwise>
                <tr>
                  <td colspan="10" class="text-center text-muted">❌ No hay recursos registrados</td>
                </tr>
              </c:otherwise>
            </c:choose>
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
