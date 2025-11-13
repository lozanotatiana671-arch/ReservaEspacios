<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>

<%!
    public String v(Object o) {
        return (o == null) ? "" : o.toString();
    }
%>

<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuarioId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String adminNombre = (String) sesion.getAttribute("usuarioNombre");
    if (adminNombre == null) adminNombre = "Admin";

    Map<String,Integer> reservasPorEstado = (Map<String,Integer>) request.getAttribute("reservasPorEstado");
    Map<String,Integer> reservasPorRecurso = (Map<String,Integer>) request.getAttribute("reservasPorRecurso");
    Map<String,Integer> reservasPorTipo = (Map<String,Integer>) request.getAttribute("reservasPorTipo");
    List<Map<String,Object>> listaRecursos = (List<Map<String,Object>>) request.getAttribute("listaRecursos");

    if (reservasPorEstado == null) reservasPorEstado = new LinkedHashMap<>();
    if (reservasPorRecurso == null) reservasPorRecurso = new LinkedHashMap<>();
    if (reservasPorTipo == null) reservasPorTipo = new LinkedHashMap<>();
    if (listaRecursos == null) listaRecursos = new ArrayList<>();

    boolean sinFiltros =
        v(request.getAttribute("fechaInicio")).isEmpty() &&
        v(request.getAttribute("fechaFin")).isEmpty() &&
        v(request.getAttribute("tipoEspacio")).isEmpty() &&
        v(request.getAttribute("estadoRecurso")).isEmpty();
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel de Administrador - Reportes</title>

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/reservas.css">

  <style>
      .pagination-container { text-align: center; margin-top: 20px; }
      .pagination button {
          margin: 4px;
          padding: 6px 12px;
          border: none;
          background: #00482B;
          color: white;
          border-radius: 5px;
      }
      .pagination button.active { background: #79C000; }

      table thead { background-color: #00482B; color: white; }
      table tbody tr:hover { background-color: #E8F5E9; }

      .mensaje-central { padding:40px; text-align:center; }

      /* NUEVO: Gráficas pequeñas tipo Power BI */
      .chart-small-container {
          width: 100%;
          height: 180px;
          padding: 10px;
      }
      .chart-small-container canvas {
          max-height:160px !important;
      }
  </style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <a class="navbar-brand" href="ListaReservasServlet">SistemaReserva</a>

    <button class="navbar-toggler" type="button" data-toggle="collapse" 
            data-target="#navbarNav"><span class="navbar-toggler-icon"></span></button>

    <div class="collapse navbar-collapse" id="navbarNav">

        <ul class="navbar-nav mr-auto">
            <li class="nav-item"><a class="nav-link" href="ListaReservasServlet">📋 Reservas</a></li>
            <li class="nav-item"><a class="nav-link" href="ListaRecursosServlet">⚙️ Recursos</a></li>
            <li class="nav-item"><a class="nav-link" href="UsuarioServlet?action=listar">👤 Usuarios</a></li>
            <li class="nav-item"><a class="nav-link active" href="ReporteServlet">📊 Reportes</a></li>
        </ul>

        <span class="navbar-text text-white mr-3">👤 <%= adminNombre %></span>
        <a href="LogoutServlet" class="btn btn-sm btn-outline-light">Cerrar Sesión</a>
    </div>
</nav>

<!-- BOTÓN MENÚ MÓVIL -->
<button class="menu-toggle" id="menuToggle"><i class="fas fa-bars"></i></button>

<div class="container-fluid">
  <div class="row">

    <!-- ⭐⭐⭐ MENÚ LATERAL COMPLETO ⭐⭐⭐ -->
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

        <a href="ReporteServlet" class="active">
            <i class="fas fa-chart-bar"></i> Reportes
        </a>
    </nav>

    <!-- ⭐ CONTENIDO ⭐ -->
    <main class="col-md-10 content-area">

        <h2><i class="bi bi-bar-chart"></i> Reporte de Espacios</h2>

        <!-- FILTROS -->
        <form action="ReporteServlet" method="get" class="mb-4" id="formFiltros">
            <div class="form-row">

                <div class="col-md-3">
                    <label>Fecha Inicio</label>
                    <input type="date" name="fechaInicio" class="form-control"
                           value="<%= v(request.getAttribute("fechaInicio")) %>">
                </div>

                <div class="col-md-3">
                    <label>Fecha Fin</label>
                    <input type="date" name="fechaFin" class="form-control"
                           value="<%= v(request.getAttribute("fechaFin")) %>">
                </div>

                <div class="col-md-3">
                    <label>Tipo</label>
                    <select name="tipoEspacio" class="form-control">
                        <option value="">Todos</option>
                        <option value="SALON">Salón</option>
                        <option value="LABORATORIO">Laboratorio</option>
                        <option value="EQUIPO">Equipo</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label>Estado</label>
                    <select name="estadoRecurso" class="form-control">
                        <option value="">Todos</option>
                        <option value="ACTIVO">Activo</option>
                        <option value="INACTIVO">Inactivo</option>
                    </select>
                </div>

            </div>
        </form>

        <!-- ⭐ MENSAJE CUANDO NO HAY FILTROS ⭐ -->
        <% if (sinFiltros) { %>

            <div class="mensaje-central">
                <i class="fas fa-info-circle" style="font-size:55px; color:#00482B;"></i>
                <h4 style="color:#00482B; font-weight:bold;">Selecciona un filtro</h4>
                <p class="text-muted">Para visualizar los reportes del sistema.</p>
            </div>

        <% } else { %>

        <!-- ⭐ GRÁFICAS PEQUEÑAS TIPO POWER BI ⭐ -->
        <div class="row text-center">

            <div class="col-md-4">
                <h6>Por Estado</h6>
                <div class="chart-small-container">
                    <canvas id="chartEstado"></canvas>
                </div>
            </div>

            <div class="col-md-4">
                <h6>Por Recurso</h6>
                <div class="chart-small-container">
                    <canvas id="chartRecurso"></canvas>
                </div>
            </div>

            <div class="col-md-4">
                <h6>Por Tipo</h6>
                <div class="chart-small-container">
                    <canvas id="chartTipo"></canvas>
                </div>
            </div>

        </div>

        <% if (!listaRecursos.isEmpty()) { %>

        <!-- TABLA -->
        <div class="mt-4">
            <table id="tablaRecursos" class="table table-bordered">
                <thead>
                  <tr>
                    <th>Nombre</th>
                    <th>Tipo</th>
                    <th>Estado</th>
                    <th>Tarifa (COP)</th>
                    <th>Ubicación</th>
                  </tr>
                </thead>
                <tbody>
                  <% for (Map<String,Object> fila : listaRecursos) { %>
                  <tr>
                    <td><%= fila.get("nombre") %></td>
                    <td><%= fila.get("tipo") %></td>
                    <td><%= fila.get("estado") %></td>
                    <td><%= fila.get("tarifa") %></td>
                    <td><%= fila.get("ubicacion") %></td>
                  </tr>
                  <% } %>
                </tbody>
            </table>
        </div>

        <!-- PAGINACIÓN 2 FILAS -->
        <div class="pagination-container">
            <div id="pagination" class="pagination"></div>
        </div>

        <% } else { %>

        <div class="mensaje-central">
            <i class="fas fa-database" style="font-size:55px; color:#00482B;"></i>
            <h4 style="color:#00482B; font-weight:bold;">No hay datos</h4>
            <p class="text-muted">Ajusta los filtros.</p>
        </div>

        <% } %>
        <% } %>

    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- GRÁFICO ESTADO -->
<script>
    const labelsEstado = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.keySet()) %>;
    const dataEstado   = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.values()) %>;

    if (labelsEstado.length > 0) {
        new Chart(document.getElementById('chartEstado'), {
          type: 'doughnut',
          data: {
            labels: labelsEstado,
            datasets: [{
              data: dataEstado,
              backgroundColor: ['#79C000','#00482B','#FBE122','#DC3545']
            }]
          }
        });
    }
</script>

<!-- GRÁFICO RECURSO -->
<script>
    const labelsRecurso = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.keySet()) %>;
    const dataRecurso   = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.values()) %>;

    if (labelsRecurso.length > 0) {
        new Chart(document.getElementById('chartRecurso'), {
          type: 'bar',
          data: {
            labels: labelsRecurso,
            datasets: [{
              data: dataRecurso,
              backgroundColor: '#007B3E',
              borderRadius: 6
            }]
          }
        });
    }
</script>

<!-- GRÁFICO TIPO -->
<script>
    const labelsTipo = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.keySet()) %>;
    const dataTipo   = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.values()) %>;

    if (labelsTipo.length > 0) {
        new Chart(document.getElementById('chartTipo'), {
          type: 'pie',
          data: {
            labels: labelsTipo,
            datasets: [{
              data: dataTipo,
              backgroundColor: ['#79C000','#007B3E','#00482B','#FBE122','#DAAA00']
            }]
          }
        });
    }
</script>

<!-- PAGINACIÓN (2 filas) -->
<script>
    const rowsPerPage = 2;
    const table = document.getElementById("tablaRecursos");

    if (table) {
        const rows = table.querySelectorAll("tbody tr");
        const pageCount = Math.ceil(rows.length / rowsPerPage);
        const pagination = document.getElementById("pagination");

        function showPage(page) {
            rows.forEach((r, i) => {
                r.style.display = (i >= (page-1)*rowsPerPage && i < page*rowsPerPage) ? "" : "none";
            });

            document.querySelectorAll(".pagination button").forEach(btn => btn.classList.remove("active"));
            document.getElementById("btn"+page).classList.add("active");
        }

        for (let i = 1; i <= pageCount; i++) {
            let btn = document.createElement("button");
            btn.id = "btn" + i;
            btn.innerText = i;
            btn.onclick = () => showPage(i);
            pagination.appendChild(btn);
        }

        showPage(1);
    }
</script>

<!-- AUTO-ENVIAR FORMULARIO AL CAMBIAR FILTRO -->
<script>
document.querySelectorAll("#formFiltros input, #formFiltros select")
    .forEach(el => {
        el.addEventListener("change", () => {
            document.getElementById("formFiltros").submit();
        });
    });
</script>

<script>
document.getElementById("menuToggle").onclick = function() {
    document.getElementById("sideMenu").classList.toggle("active");
};
</script>

</body>
</html>
