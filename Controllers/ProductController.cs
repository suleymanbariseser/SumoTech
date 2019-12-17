using SumoTech.Entity;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class ProductController : Controller
    {
        public Item getItem(int id)
        {
            Item item = new Item();
            string conString = ConfigurationManager.ConnectionStrings["dataConnection"].ConnectionString;
            SqlConnection connection = new SqlConnection(conString);
            try
            {
                connection.Open();
            }
            catch (Exception ex)
            {
                Response.Write("error" + ex.ToString());
                connection.Close();
                return null;
            }

            string cmdString = "SELECT * FROM Item where itemid = " + id;
            SqlCommand cmd = new SqlCommand(cmdString, connection);
            SqlDataReader nwReader = cmd.ExecuteReader();
            while (nwReader.Read())
            {
                item.Id = (int)nwReader["itemid"];
                item.Brand = (string)nwReader["brand"];
                item.Name = (string)nwReader["name_"];
                item.Price = (double)nwReader["price"];
                item.Production_year = (int)nwReader["production_year"];
                item.Description = (string)nwReader["item_description"];
                item.Type = (string)nwReader["item_type"];
            }
            connection.Close();
            return item;
        }
        // GET: Product
        public ActionResult Detail(int id)
        {
            return View(getItem(id));
        }
    }
}