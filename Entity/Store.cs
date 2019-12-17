using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Store
    {
        public int Id { get; set; }
        public String Address { get; set; }
        public String Phone { get; set; }
        public List<String> Employees { get; set; }
        public List<Item> List { get; set; }
    }
}