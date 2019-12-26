using SumoTech.Entity;
using SumoTech.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SumoTech.Controllers
{
    public class OrderLineController : Controller
    {
        DataContext dataContext = new DataContext();
        // GET: OrderLine
        public ActionResult Edit(int Id)
        {
            List<OrderedItem> OrderedItems = new List<OrderedItem>();
            string cmd = "SELECT * FROM OrderedItem WHERE orderlineid = " + Id;
            dataContext.OpenConnection();
            SqlCommand sqlCommand = new SqlCommand(cmd, dataContext.GetConnection());
            SqlDataReader sqlDataReader = sqlCommand.ExecuteReader();
            while (sqlDataReader.Read())
            {
                OrderedItem orderedItem = new OrderedItem();
                orderedItem.OrderLineId = (int)sqlDataReader["orderlineid"];
                orderedItem.ItemId = (int)sqlDataReader["itemid"];
                orderedItem.StoreId = (int)sqlDataReader["storeid"];
                orderedItem.Quantity = (int)sqlDataReader["quantity"];
               // orderedItem.StoreId = (int)sqlDataReader["storeid"];
                OrderedItems.Add(orderedItem);
            }
            dataContext.CloseConnection();
            cmd = "SELECT * FROM OrderLine WHERE orderlineid = " + Id;
            OrderLine orderLine = new OrderLine();
            dataContext.OpenConnection();
            sqlCommand = new SqlCommand(cmd, dataContext.GetConnection());
            sqlDataReader = sqlCommand.ExecuteReader();
            while (sqlDataReader.Read())
            {
                orderLine.Id = (int)sqlDataReader["orderlineid"];
                orderLine.CustomerId = (int)sqlDataReader["customerid"];
                orderLine.Destination_address = (string)sqlDataReader["destination_address"];
                orderLine.Price = (double)sqlDataReader["order_price"];
                orderLine.Date = (DateTime)sqlDataReader["order_date"];
            }
            orderLine.OrderedItems = OrderedItems;
            dataContext.CloseConnection();

            return View(orderLine);
        }
        public ActionResult NewOrderedItem(int orderlineid, int storeid,int itemid, int quantity)
        {
            int temp = 0;
            string control = "SELECT quantity FROM StoreItem WHERE itemid = " + itemid + " AND storeid = " + storeid;
            dataContext.OpenConnection();
            SqlDataReader sqlDataReader = dataContext.Execute(control);
            while (sqlDataReader.Read())
            {
                temp = (int)sqlDataReader["quantity"];
            }
            dataContext.CloseConnection();
            Response.Write("sadad");
            string cmd = "INSERT INTO OrderedItem (orderlineid, itemid, storeid,quantity)" +
                " VALUES (" + orderlineid + ", " + storeid + "," + itemid + ", " + quantity + ")";

            SqlCommand sqlCommand = new SqlCommand(cmd, dataContext.GetConnection());
            dataContext.OpenConnection();
            try
            {
                sqlCommand.ExecuteNonQuery();
                return RedirectToAction("Edit", new { Id = orderlineid});
            }
            catch
            {
                return RedirectToAction("Index", "Error");
            }
            dataContext.CloseConnection();
            return View();
        }
    }
}