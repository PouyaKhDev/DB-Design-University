function toggleCard(cardId) {
  const card = document.getElementById(`card-${cardId}`);
  card.classList.toggle("active");
}

async function handleExecute(event, queryName, noParams = false) {
  if (!noParams) {
    event.preventDefault();
  }

  const resultArea = document.getElementById(`result-${queryName}`);
  resultArea.innerHTML = '<div class="loading">Executing query...</div>';

  let params = {};

  // Gather parameters if they exist
  if (!noParams) {
    const form = event.target;
    const formData = new FormData(form);
    for (let [key, value] of formData.entries()) {
      // Convert numbers
      if (!isNaN(value) && value.trim() !== "") {
        params[key] = Number(value);
      } else {
        params[key] = value;
      }
    }
  }

  try {
    const response = await fetch("/execute/", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": getCookie("csrftoken"),
      },
      body: JSON.stringify({
        query_name: queryName,
        params: params,
      }),
    });

    const data = await response.json();

    if (response.ok && data.success) {
      renderTable(data.data, resultArea);
    } else {
      resultArea.innerHTML = `<div class="error-msg">Error: ${data.error}</div>`;
    }
  } catch (error) {
    resultArea.innerHTML = `<div class="error-msg">Network Error: ${error.message}</div>`;
  }
}

function renderTable(data, container) {
  if (!data || data.length === 0) {
    container.innerHTML = '<div class="empty-msg">No results found.</div>';
    return;
  }

  const columns = Object.keys(data[0]);

  let html = '<table class="result-table"><thead><tr>';
  columns.forEach((col) => {
    // Format column name (replace underscores with spaces and capitalize)
    const formattedCol = col.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
    html += `<th>${formattedCol}</th>`;
  });
  html += "</tr></thead><tbody>";

  data.forEach((row) => {
    html += "<tr>";
    columns.forEach((col) => {
      let val = row[col];
      if (val === null) val = "NULL";
      html += `<td>${val}</td>`;
    });
    html += "</tr>";
  });

  html += "</tbody></table>";
  container.innerHTML = html;
}

// Helper to get CSRF token from cookies
function getCookie(name) {
  let cookieValue = null;
  if (document.cookie && document.cookie !== "") {
    const cookies = document.cookie.split(";");
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i].trim();
      if (cookie.substring(0, name.length + 1) === name + "=") {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}
