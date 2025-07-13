defmodule F1DashboardWeb.DataLiveTest do
  use F1DashboardWeb.ConnCase

  import Phoenix.LiveViewTest
  import F1Dashboard.LiveDataFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_data(_) do
    data = data_fixture()
    %{data: data}
  end

  describe "Index" do
    setup [:create_data]

    test "lists all data", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/data")

      assert html =~ "Listing Data"
    end

    test "saves new data", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/data")

      assert index_live |> element("a", "New Data") |> render_click() =~
               "New Data"

      assert_patch(index_live, ~p"/data/new")

      assert index_live
             |> form("#data-form", data: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#data-form", data: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/data")

      html = render(index_live)
      assert html =~ "Data created successfully"
    end

    test "updates data in listing", %{conn: conn, data: data} do
      {:ok, index_live, _html} = live(conn, ~p"/data")

      assert index_live |> element("#data-#{data.id} a", "Edit") |> render_click() =~
               "Edit Data"

      assert_patch(index_live, ~p"/data/#{data}/edit")

      assert index_live
             |> form("#data-form", data: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#data-form", data: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/data")

      html = render(index_live)
      assert html =~ "Data updated successfully"
    end

    test "deletes data in listing", %{conn: conn, data: data} do
      {:ok, index_live, _html} = live(conn, ~p"/data")

      assert index_live |> element("#data-#{data.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#data-#{data.id}")
    end
  end

  describe "Show" do
    setup [:create_data]

    test "displays data", %{conn: conn, data: data} do
      {:ok, _show_live, html} = live(conn, ~p"/data/#{data}")

      assert html =~ "Show Data"
    end

    test "updates data within modal", %{conn: conn, data: data} do
      {:ok, show_live, _html} = live(conn, ~p"/data/#{data}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Data"

      assert_patch(show_live, ~p"/data/#{data}/show/edit")

      assert show_live
             |> form("#data-form", data: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#data-form", data: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/data/#{data}")

      html = render(show_live)
      assert html =~ "Data updated successfully"
    end
  end
end
