<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>

<%!
    // ✅ Función para evitar valores null (DEBE IR AQUÍ)
    public String v(Object o) {
        return (o == null) ? "" : o.toString();
    }
%>

<%
    // 🔹 Validación de sesión del administrador
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String adminNombre = (String) sesion.getAttribute("usuarioNombre");
    if (adminNombre == null) adminNombre = "Admin";

    // 🔹 Obtener datos
    Map<String,Integer> reservasPorEstado = (Map<String,Integer>) request.getAttribute("reservasPorEstado");
    Map<String,Integer> reservasPorRecurso = (Map<String,Integer>) request.getAttribute("reservasPorRecurso");
    List<Map<String,Object>> listaRecursos = (List<Map<String,Object>>) request.getAttribute("listaRecursos");

    if (reservasPorEstado == null) reservasPorEstado = new LinkedHashMap<>();
    if (reservasPorRecurso == null) reservasPorRecurso = new LinkedHashMap<>();
    if (listaRecursos == null) listaRecursos = new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel de Administrador - Reportes</title>

  <!-- Bootstrap y Font Awesome -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <!-- CSS personalizados -->
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/reservas.css">

</head>

<body>

<!-- 🔹 Navbar Administrador -->
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
        <a href="LogoutServlet" class="btn btn-sm btn-outline-light">Cerrar Sesión</a>
    </div>
</nav>

<!-- Botón menú móvil -->
<button class="menu-toggle" id="menuToggle"><i class="fas fa-bars"></i></button>

<div class="container-fluid">
  <div class="row" style="margin-right: -20px;">

    <!-- 🔹 Menú lateral (NO SE TOCÓ NADA) -->
    <nav class="col-md-2 side-menu" id="sideMenu">
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
        <a href="ReporteServlet" class="active"><i class="fas fa-chart-bar"></i> Reportes</a>
    </nav>

    <!-- 🔹 Contenido principal -->
    <main class="col-md-10 content-area">

        <h2><i class="bi bi-bar-chart"></i> Reporte de Espacios</h2>

        <!-- 🔹 Formulario filtros -->
        <form action="ReporteServlet" method="get" class="mb-4">
            <div class="row">

                <!-- Fecha inicio -->
                <div class="col-md-6 mb-3">
                    <label for="fechaInicio">Fecha Inicio</label>
                    <input type="date" id="fechaInicio" name="fechaInicio" class="form-control"
                           value="<%= v(request.getAttribute("fechaInicio")) %>">
                </div>

                <!-- Fecha fin -->
                <div class="col-md-6 mb-3">
                    <label for="fechaFin">Fecha Fin</label>
                    <input type="date" id="fechaFin" name="fechaFin" class="form-control"
                           value="<%= v(request.getAttribute("fechaFin")) %>">
                </div>

                <!-- Tipo -->
                <div class="col-md-6 mb-3">
                    <label for="tipo">Tipo de espacio</label>
                    <select id="tipo" name="tipo" class="form-control">
                        <option value="">Todos</option>
                        <option value="SALON" <%= "SALON".equals(v(request.getAttribute("tipo"))) ? "selected" : "" %>>Salón</option>
                        <option value="LABORATORIO" <%= "LABORATORIO".equals(v(request.getAttribute("tipo"))) ? "selected" : "" %>>Laboratorio</option>
                        <option value="EQUIPO" <%= "EQUIPO".equals(v(request.getAttribute("tipo"))) ? "selected" : "" %>>Equipo</option>
                    </select>
                </div>

                <!-- Estado -->
                <div class="col-md-6 mb-3">
                    <label for="estado">Estado</label>
                    <select id="estado" name="estado" class="form-control">
                        <option value="">Todos</option>
                        <option value="ACTIVO" <%= "ACTIVO".equals(v(request.getAttribute("estado"))) ? "selected" : "" %>>Activo</option>
                        <option value="INACTIVO" <%= "INACTIVO".equals(v(request.getAttribute("estado"))) ? "selected" : "" %>>Inactivo</option>
                    </select>
                </div>

                <!-- Capacidad -->
                <div class="col-md-6 mb-3">
                    <label for="capacidad">Capacidad</label>
                    <input type="number" id="capacidad" name="capacidad" class="form-control" min="1"
                           value="<%= v(request.getAttribute("capacidad")) %>">
                </div>

                <!-- Botones -->
                <div class="col-md-12 text-right mt-3">
                  <button type="submit" class="btn btn-success">
                    <i class="fas fa-search"></i> Generar Reporte
                  </button>

                  <!-- Exportar PDF -->
                  <a href="<%= request.getContextPath() %>/ReporteExportServlet?tipo=pdf
                    &fechaInicio=<%= v(request.getAttribute("fechaInicio")) %>
                    &fechaFin=<%= v(request.getAttribute("fechaFin")) %>
                    &tipo=<%= v(request.getAttribute("tipo")) %>
                    &estado=<%= v(request.getAttribute("estado")) %>
                    &capacidad=<%= v(request.getAttribute("capacidad")) %>"
                     class="btn btn-danger ml-2">
                    <i class="fas fa-file-pdf"></i> Exportar PDF
                  </a>

                  <!-- Exportar Excel -->
                  <a href="<%= request.getContextPath() %>/ReporteExportServlet?tipo=excel
                    &fechaInicio=<%= v(request.getAttribute("fechaInicio")) %>
                    &fechaFin=<%= v(request.getAttribute("fechaFin")) %>
                    &tipo=<%= v(request.getAttribute("tipo")) %>
                    &estado=<%= v(request.getAttribute("estado")) %>
                    &capacidad=<%= v(request.getAttribute("capacidad")) %>"
                     class="btn btn-primary ml-2">
                    <i class="fas fa-file-excel"></i> Exportar Excel
                  </a>
                </div>

            </div>
        </form>

        <!-- 🔹 Gráficas -->
        <div class="row" id="graficasContainer">
          <div class="col-md-6">
            <div class="rf-chart-section">
              <h5><i class="bi bi-pie-chart"></i> Reservas por Estado</h5>
              <canvas id="chartEstado"></canvas>
            </div>
          </div>

          <div class="col-md-6">
            <div class="rf-chart-section">
              <h5><i class="bi bi-bar-chart-line"></i> Reservas por Recurso</h5>
              <canvas id="chartRecurso"></canvas>
            </div>
          </div>
        </div>

        <!-- 🔹 Tabla -->
        <div class="rf-table-section mt-4">
          <table class="table table-striped table-bordered">
            <thead class="thead-dark">
              <tr>
                <th>Nombre</th>
                <th>Tipo</th>
                <th>Estado</th>
                <th>Capacidad</th>
                <th>Tarifa (COP)</th>
                <th>Disponible</th>
                <th>Ubicación</th>
              </tr>
            </thead>
            <tbody>
              <%
                if (listaRecursos != null && !listaRecursos.isEmpty()) {
                  for (Map<String, Object> fila : listaRecursos) {
              %>
              <tr>
                <td><%= fila.get("nombre") %></td>
                <td><%= fila.get("tipo") %></td>
                <td><%= fila.get("estado") %></td>
                <td><%= fila.get("capacidad") %></td>
                <td><%= fila.get("tarifa") %></td>
                <td><%= "ACTIVO".equalsIgnoreCase(v(fila.get("estado"))) ? "Sí" : "No" %></td>
                <td><%= fila.get("ubicacion") %></td>
              </tr>
              <% }} else { %>
              <tr>
                <td colspan="7" class="text-center text-muted">No hay datos disponibles</td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>

    </main>
  </div>
</div>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const labelsEstado = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.keySet()) %>;
    const dataEstado   = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.values()) %>;

    const labelsRecurso = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.keySet()) %>;
    const dataRecurso   = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.values()) %>;

    new Chart(document.getElementById('chartEstado'), {
      type: 'doughnut',
      data: {
        labels: labelsEstado,
        datasets: [{
          data: dataEstado,
          backgroundColor: ['#79C000', '#FBE122', '#00482B', '#DC3545'],
          borderWidth: 0
        }]
      },
      options: { plugins: { legend: { position: 'bottom' } } }
    });

    new Chart(document.getElementById('chartRecurso'), {
      type: 'bar',
      data: {
        labels: labelsRecurso,
        datasets: [{
          label: 'Reservas',
          data: dataRecurso,
          backgroundColor: '#007B3E',
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
      }
    });
</script>

<!-- Menú móvil -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.getElementById('menuToggle');
    const sideMenu = document.getElementById('sideMenu');
    if (menuToggle && sideMenu) {
      menuToggle.addEventListener('click', () => sideMenu.classList.toggle('active'));
    }
  });
</script>

</body>
</html>
