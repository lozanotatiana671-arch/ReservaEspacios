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

  <!-- CSS externos de tu frontend -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin-panel.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sub_menuadmin.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/reservas.css">

  <style>
      /* Tarjetas de los gráficos */
      .chart-card {
          background: #FFFFFF;
          border-radius: 18px;
          padding: 20px;
          margin-bottom: 25px;
          box-shadow: 0 3px 10px rgba(0,0,0,0.08);
          text-align:center;
          border: 1px solid #E0E0E0;
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
          display:flex;
          align-items:center;
          justify-content:center;
      }

      .chart-small-container canvas {
          max-height: 170px !important;
      }

      .chart-legend {
          margin-top:12px;
          border-top:1px solid #F0F0F0;
          padding-top:10px;
          display:flex;
          flex-wrap:wrap;
          justify-content:center;
          gap:10px;
      }

      .legend-item {
          display:flex;
          align-items:center;
          font-size:12px;
          color:#555;
          background:#F8F9FA;
          padding:4px 8px;
          border-radius:10px;
      }

      .legend-color {
          width:14px;
          height:14px;
          border-radius:4px;
          margin-right:6px;
      }

      /* Paginación centrada */
      .pagination-container {
          text-align: center;
          margin-top: 15px;
      }
      .pagination {
          display: inline-flex;
          align-items: center;
      }
      .pagination button {
          margin: 0 3px;
          padding: 6px 12px;
          border: none;
          background: #00482B;
          color: white;
          border-radius: 20px;
          font-size: 13px;
      }
      .pagination button.active {
          background: #79C000;
      }

      table thead { background-color: #00482B; color: white; }
      table tbody tr:hover { background-color: #E8F5E9; }

      .mensaje-central { padding:40px; text-align:center; }

      /* Filtro encima de la tabla */
      .table-filter-card {
          background:#F5FFF4;
          border-radius:12px;
          padding:15px 20px;
          border:1px solid #79C000;
          margin-top:20px;
      }
      .table-filter-title {
          font-weight:600;
          color:#00482B;
          margin-bottom:10px;
          font-size:14px;
      }
      .table-filter-card .form-control {
          border-radius:20px;
          border:1px solid #79C000;
          font-size:13px;
      }
      .table-filter-card label {
          font-size:12px;
          color:#00482B;
          margin-bottom:2px;
      }

      .btn-success-custom {
          background:#007B3E;
          border-color:#007B3E;
      }
      .btn-success-custom:hover {
          background:#00482B;
          border-color:#00482B;
      }
      .btn-danger-custom {
          background:#DC3545;
          border-color:#DC3545;
      }
      .btn-primary-custom {
          background:#1F77B4;
          border-color:#1F77B4;
      }
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

    <!-- MENÚ LATERAL (sin cambios) -->
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

        <h2 class="mt-3 mb-4 text-success">
            <i class="bi bi-bar-chart"></i> Dashboard de Reportes
        </h2>

        <!-- FILTROS PRINCIPALES -->
        <form action="ReporteServlet" method="get" class="mb-3" id="formFiltros">
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
                        <option value="SALON" <%= "SALON".equals(v(request.getAttribute("tipo"))) ? "selected" : "" %>>Salón</option>
                        <option value="LABORATORIO" <%= "LABORATORIO".equals(v(request.getAttribute("tipo"))) ? "selected" : "" %>>Laboratorio</option>
                        <option value="EQUIPO" <%= "EQUIPO".equals(v(request.getAttribute("tipo"))) ? "selected" : "" %>>Equipo</option>
                    </select>
                </div>

                <div class="col-md-3">
                    <label>Estado</label>
                    <select name="estado" class="form-control">
                        <option value="">Todos</option>
                        <option value="ACTIVO" <%= "ACTIVO".equals(v(request.getAttribute("estado"))) ? "selected" : "" %>>Activo</option>
                        <option value="INACTIVO" <%= "INACTIVO".equals(v(request.getAttribute("estado"))) ? "selected" : "" %>>Inactivo</option>
                    </select>
                </div>

            </div>

            <div class="text-right mt-3">
                <button type="submit" class="btn btn-success-custom">
                    <i class="fas fa-search"></i> Generar
                </button>

                <a class="btn btn-danger-custom ml-2"
                   href="ReporteExportServlet?tipo=pdf&fechaInicio=<%=v(request.getAttribute("fechaInicio"))%>&fechaFin=<%=v(request.getAttribute("fechaFin"))%>&tipo=<%=v(request.getAttribute("tipo"))%>&estado=<%=v(request.getAttribute("estado"))%>">
                    <i class="fas fa-file-pdf"></i> PDF
                </a>

                <a class="btn btn-primary-custom ml-2"
                   href="ReporteExportServlet?tipo=excel&fechaInicio=<%=v(request.getAttribute("fechaInicio"))%>&fechaFin=<%=v(request.getAttribute("fechaFin"))%>&tipo=<%=v(request.getAttribute("tipo"))%>&estado=<%=v(request.getAttribute("estado"))%>">
                    <i class="fas fa-file-excel"></i> Excel
                </a>
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
                    <div id="legendEstado" class="chart-legend"></div>
                </div>
            </div>

            <!-- RECURSO -->
            <div class="col-md-4">
                <div class="chart-card">
                    <div class="chart-title">Cantidad por Recurso</div>
                    <div class="chart-small-container">
                        <canvas id="chartRecurso"></canvas>
                    </div>
                    <div id="legendRecurso" class="chart-legend"></div>
                </div>
            </div>

            <!-- TIPO -->
            <div class="col-md-4">
                <div class="chart-card">
                    <div class="chart-title">Distribución por Tipo</div>
                    <div class="chart-small-container">
                        <canvas id="chartTipo"></canvas>
                    </div>
                    <div id="legendTipo" class="chart-legend"></div>
                </div>
            </div>

        </div>

        <!-- FILTRO PARA LA TABLA -->
        <% if (!listaRecursos.isEmpty()) { %>
        <div class="table-filter-card">
            <div class="table-filter-title">
                <i class="fas fa-filter"></i> Filtro rápido de espacios
            </div>
            <div class="form-row">
                <div class="col-md-4 mb-2">
                    <label>Buscar por nombre / ubicación</label>
                    <input type="text" id="filtroTextoTabla" class="form-control" placeholder="Ej: cancha, laboratorio...">
                </div>
                <div class="col-md-4 mb-2">
                    <label>Tipo</label>
                    <select id="filtroTipoTabla" class="form-control">
                        <option value="">Todos</option>
                        <option value="SALON">Salón</option>
                        <option value="LABORATORIO">Laboratorio</option>
                        <option value="EQUIPO">Equipo</option>
                    </select>
                </div>
                <div class="col-md-4 mb-2">
                    <label>Estado</label>
                    <select id="filtroEstadoTabla" class="form-control">
                        <option value="">Todos</option>
                        <option value="DISPONIBLE">Disponible</option>
                        <option value="OCUPADO">Ocupado</option>
                    </select>
                </div>
            </div>
        </div>
        <% } %>

        <!-- TABLA -->
        <% if (!listaRecursos.isEmpty()) { %>

        <table id="tablaRecursos" class="table table-bordered mt-3">
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
     GRÁFICOS + LEYENDAS
================================ -->
<script>
/* Colores corporativos */
const verde      = "#007B3E";
const verdeClaro = "#79C000";
const azul       = "#1F77B4";
const amarillo   = "#FBE122";
const rojo       = "#DC3545";

/* Plugin total al centro (para donut) */
const centerTotal = {
    id: 'centerTotal',
    afterDraw(chart) {
        const dataset = chart.config.data.datasets[0];
        if (!dataset || !dataset.data || dataset.data.length === 0) return;

        const total = dataset.data.reduce((a,b)=>a+b,0);
        const {ctx, chartArea} = chart;
        if (!chartArea) return;

        const {left, right, top, bottom} = chartArea;

        ctx.save();
        ctx.font = "bold 16px Arial";
        ctx.fillStyle = "#00482B";
        ctx.textAlign = "center";
        ctx.textBaseline = "middle";
        ctx.fillText(total, (left+right)/2, (top+bottom)/2);
        ctx.restore();
    }
};

/* Util para crear leyendas debajo de cada gráfico */
function construirLeyenda(containerId, labels, data, colors) {
    const cont = document.getElementById(containerId);
    if (!cont) return;
    cont.innerHTML = "";
    for (let i = 0; i < labels.length; i++) {
        const item = document.createElement("div");
        item.className = "legend-item";

        const colorBox = document.createElement("div");
        colorBox.className = "legend-color";
        colorBox.style.background = colors[i % colors.length];

        const text = document.createElement("span");
        text.textContent = labels[i] + " (" + data[i] + ")";

        item.appendChild(colorBox);
        item.appendChild(text);
        cont.appendChild(item);
    }
}

/* ===== ESTADO ===== */
const labelsEstado = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.keySet()) %>;
const dataEstado   = <%= reservasPorEstado.isEmpty() ? "[]" : new JSONArray(reservasPorEstado.values()) %>;

if (labelsEstado.length > 0) {
    const coloresEstado = [verdeClaro, azul, amarillo, rojo];

    new Chart(document.getElementById('chartEstado'), {
        type: 'doughnut',
        plugins: [centerTotal],
        data: {
            labels: labelsEstado,
            datasets: [{
                data: dataEstado,
                backgroundColor: coloresEstado,
                borderWidth: 0,
                hoverOffset: 4
            }]
        },
        options: {
            cutout: "65%",
            plugins: { legend: { display: false } }
        }
    });

    construirLeyenda("legendEstado", labelsEstado, dataEstado, coloresEstado);
}

/* ===== RECURSO ===== */
const labelsRecurso = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.keySet()) %>;
const dataRecurso   = <%= reservasPorRecurso.isEmpty() ? "[]" : new JSONArray(reservasPorRecurso.values()) %>;

if (labelsRecurso.length > 0) {
    const coloresRecurso = labelsRecurso.map((_, i) =>
        [verde, azul, verdeClaro, amarillo, rojo][i % 5]
    );

    new Chart(document.getElementById('chartRecurso'), {
        type: 'bar',
        data: {
            labels: labelsRecurso,
            datasets: [{
                data: dataRecurso,
                backgroundColor: coloresRecurso,
                borderRadius: 12,
                barThickness: 26
            }]
        },
        options: {
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, grid: { color: "rgba(0,0,0,0.05)" } },
                x: { ticks: { color: "#333" } }
            }
        }
    });

    construirLeyenda("legendRecurso", labelsRecurso, dataRecurso, coloresRecurso);
}

/* ===== TIPO ===== */
const labelsTipo = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.keySet()) %>;
const dataTipo   = <%= reservasPorTipo.isEmpty() ? "[]" : new JSONArray(reservasPorTipo.values()) %>;

if (labelsTipo.length > 0) {
    const coloresTipo = [verdeClaro, azul, amarillo, verde];

    new Chart(document.getElementById('chartTipo'), {
        type: 'pie',
        data: {
            labels: labelsTipo,
            datasets: [{
                data: dataTipo,
                backgroundColor: coloresTipo,
                borderWidth: 0
            }]
        },
        options: {
            plugins: { legend: { display: false } }
        }
    });

    construirLeyenda("legendTipo", labelsTipo, dataTipo, coloresTipo);
}
</script>

<!-- PAGINACIÓN Y FILTRO DE TABLA -->
<script>
/* Paginación 2 filas por página */
const rowsPerPage = 2;
const table = document.getElementById("tablaRecursos");

let currentPage = 1;

function aplicarPaginacion() {
    if (!table) return;
    const rows = Array.from(table.querySelectorAll("tbody tr"))
        .filter(r => r.style.display !== "none" || !r.dataset.filtered); // sólo filas visibles por filtros

    const pagination = document.getElementById("pagination");
    if (!pagination) return;

    const pageCount = Math.max(1, Math.ceil(rows.length / rowsPerPage));
    if (currentPage > pageCount) currentPage = pageCount;

    // Ocultar/mostrar filas
    rows.forEach((r, i) => {
        const start = (currentPage - 1) * rowsPerPage;
        const end   = currentPage * rowsPerPage;
        r.style.display = (i >= start && i < end) ? "" : "none";
    });

    // Reconstruir controles
    pagination.innerHTML = "";

    const btnPrev = document.createElement("button");
    btnPrev.innerText = "Anterior";
    btnPrev.disabled = currentPage === 1;
    btnPrev.onclick = () => { if (currentPage > 1) { currentPage--; aplicarPaginacion(); } };
    pagination.appendChild(btnPrev);

    for (let i = 1; i <= pageCount; i++) {
        const btn = document.createElement("button");
        btn.id = "btn" + i;
        btn.innerText = i;
        if (i === currentPage) btn.classList.add("active");
        btn.onclick = () => { currentPage = i; aplicarPaginacion(); };
        pagination.appendChild(btn);
    }

    const btnNext = document.createElement("button");
    btnNext.innerText = "Siguiente";
    btnNext.disabled = currentPage === pageCount;
    btnNext.onclick = () => { if (currentPage < pageCount) { currentPage++; aplicarPaginacion(); } };
    pagination.appendChild(btnNext);
}

/* Filtro de tabla (texto, tipo, estado) */
function aplicarFiltrosTabla() {
    if (!table) return;
    const texto   = document.getElementById("filtroTextoTabla")  ? document.getElementById("filtroTextoTabla").value.toLowerCase() : "";
    const tipo    = document.getElementById("filtroTipoTabla")   ? document.getElementById("filtroTipoTabla").value : "";
    const estado  = document.getElementById("filtroEstadoTabla") ? document.getElementById("filtroEstadoTabla").value : "";

    const rows = table.querySelectorAll("tbody tr");

    rows.forEach(r => {
        const nombre    = r.cells[0].innerText.toLowerCase();
        const tipoCol   = r.cells[1].innerText.toUpperCase();
        const estadoCol = r.cells[2].innerText.toUpperCase();
        const ubic      = r.cells[4].innerText.toLowerCase();

        let visible = true;

        if (texto && !(nombre.includes(texto) || ubic.includes(texto))) {
            visible = false;
        }
        if (tipo && tipoCol !== tipo.toUpperCase()) {
            visible = false;
        }
        if (estado && estadoCol !== estado.toUpperCase()) {
            visible = false;
        }

        if (visible) {
            r.style.display = "";
            r.removeAttribute("data-filtered");
        } else {
            r.style.display = "none";
            r.setAttribute("data-filtered","true");
        }
    });

    currentPage = 1;
    aplicarPaginacion();
}

/* Inicialización */
if (table) {
    const filtroTextoTabla  = document.getElementById("filtroTextoTabla");
    const filtroTipoTabla   = document.getElementById("filtroTipoTabla");
    const filtroEstadoTabla = document.getElementById("filtroEstadoTabla");

    if (filtroTextoTabla)  filtroTextoTabla.addEventListener("keyup",  aplicarFiltrosTabla);
    if (filtroTipoTabla)   filtroTipoTabla.addEventListener("change", aplicarFiltrosTabla);
    if (filtroEstadoTabla) filtroEstadoTabla.addEventListener("change", aplicarFiltrosTabla);

    aplicarPaginacion();
}
</script>

<!-- Auto actualizar filtros principales -->
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
