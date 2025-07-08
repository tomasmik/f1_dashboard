defmodule F1DashboardWeb.ErrorJSONTest do
  use F1DashboardWeb.ConnCase, async: true

  test "renders 404" do
    assert F1DashboardWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert F1DashboardWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
