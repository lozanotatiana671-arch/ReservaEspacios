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
        v(request.getAttribute("tipo")).isEmpty() &&
        v(request.getAttribute("estado")).isEmpty();
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard - Reportes</title>

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/reservas.css">

  <style>

      .chart-card {
          background: white;
          border-radius: 18px;
          padding: 22px;
          margin-bottom: 25px;
          box-shadow: 0 3px 12px rgba(0,0,0,0.10);
          text-align:center;
      }

      .chart-title {
          font-weight: 700;
          color:#00482B;
          font-size:15px;
          margin-bottom:10px;
      }

      .chart-small-container {
          width: 100%;
          height: 200px;
      }

      .chart-small-container canvas {
          max-height: 180px !important;
      }

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
  </style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <a class="navbar-brand" href="ListaReservasServlet">SistemaReserva</a>

    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
    </button>

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

<button class="menu-toggle" id="menuToggle"><i class="fas fa-bars"></i></button>

<div class="container-fluid">
  <div class="row">

    <!-- MENÚ LATERAL -->
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

    <!-- CONTENIDO -->
    <main class="col-md-10 content-area">

        <h2 class="mt-3 mb-4 text-success"><i class="bi bi-bar-chart"></i> Dashboard de Reportes</h2>

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
                    <select name="tipo" class="form-control">
                        <option value="">Todos</option>
                        <option value="SALON">Salón</option>
                        <option value="LABORATORIO">Laboratorio</option>
                        <option value="EQUIPO">Equipo</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label>Estado</label>
                    <select name="estado" class="form-control">
                        <option value="">Todos</option>
                        <option value="ACTIVO">Activo</option>
                        <option value="INACTIVO">Inactivo</option>
                    </select>
                </div>

            </div>
        </form>

        <!-- CUANDO NO HAY FILTROS -->
        <% if (sinFiltros) { %>

            <div class="mensaje-central">
                <i class="fas fa-info-circle" style="font-size:55px; color:#00482B;"></i>
                <h4 style="color:#00482B; font-weight:bold;">Selecciona un filtro</h4>
                <p class="text-muted">Para visualizar los reportes del sistema.</p>
            </div>

        <% } else { %>

        <!-- DASHBOARD -->
        <div class="row">

            <!-- ESTADO -->
            <div class="col-md-4">
                <div class="chart-card">
                    <div class="chart-title">Distribución por Estado</div>
                    <div class="chart-small-container">
                        <canvas id="chartEstado"></canvas>
                    </div>
                </div>
            </div>

            <!-- RECURSO -->
            <div class="col-md-4">
                <div class="chart-card">
                    <div class="chart-title">Cantidad por Recurso</div>
                    <div class="chart-small-container">
                        <canvas id="chartRecurso"></canvas>
                    </div>
                </div>
            </div>

            <!-- TIPO -->
            <div class="col-md-4">
                <div class="chart-card">
                    <div class="chart-title">Distribución por Tipo</div>
                    <div class="chart-small-container">
                        <canvas id="chartTipo"></canvas>
                    </div>
                </div>
            </div>

        </div>

        <!-- TABLA -->
        <% if (!listaRecursos.isEmpty()) { %>

        <table id="tablaRecursos" class="table table-bordered mt-4">
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

<!-- ================================
     GRÁFICOS POWER BI
================================ -->

<script>
/* COLores */
const verde = "#007B3E";
const verdeClaro = "#79C000";
const azul = "#1F77B4";
const amarillo = "#FBE122";
const rojo = "#DC3545";

/* Plugin total al centro */
const centerTotal = {
    id: 'centerTotal',
    afterDraw(chart) {
        const total = chart.config.data.datasets[0].data.reduce((a,b)=>a+b,0);
        const {ctx, chartArea: {left, right, top, bottom}} = chart;

        ctx.save();
        ctx.font = "bold 18px Arial";
        ctx.fillStyle = "#00482B";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillText(total, (left+right)/2, (top+bottom)/2);
        ctx.restore();
    }
};

const labelsEstado = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.keySet()) %>;
const dataEstado = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.values()) %>;

if (labelsEstado.length > 0) {
    new Chart(document.getElementById('chartEstado'), {
        type: 'doughnut',
        plugins: [centerTotal],
        data: {
            labels: labelsEstado,
            datasets: [{
                data: dataEstado,
                backgroundColor: [verdeClaro, azul, amarillo, rojo],
                borderWidth: 0,
                hoverOffset: 4
            }]
        },
        options: {
            cutout: "65%",
            plugins: { legend: { display: false } }
        }
    });
}

/* RECURSO */
const labelsRecurso = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.keySet()) %>;
const dataRecurso = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.values()) %>;

if (labelsRecurso.length > 0) {
    new Chart(document.getElementById('chartRecurso'), {
        type: 'bar',
        data: {
            labels: labelsRecurso,
            datasets: [{
                data: dataRecurso,
                backgroundColor: verde,
                borderRadius: 12,
                barThickness: 28
            }]
        },
        options: {
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, grid: { color: "rgba(0,0,0,0.05)" }},
                x: { ticks: { color: "#333" } }
            }
        }
    });
}

/* TIPO */
const labelsTipo = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.keySet()) %>;
const dataTipo = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.values()) %>;

if (labelsTipo.length > 0) {
    new Chart(document.getElementById('chartTipo'), {
        type: 'pie',
        data: {
            labels: labelsTipo,
            datasets: [{
                data: dataTipo,
                backgroundColor: [verdeClaro, azul, amarillo, verde],
                borderWidth: 0
            }]
        },
        options: { plugins: { legend: { display: false } } }
    });
}
</script>

<!-- PAGINACIÓN -->
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

<!-- Auto actualizar -->
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
