using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Store
    {
        [Required]
        public int Id { get; set; }
        [Required]
        public string Country { get; set; }
        [Required]
        public string City { get; set; }
        [Required]
        public String Address { get; set; }
        [Required]
        public String Phone { get; set; }
        public List<Employee> Employees { get; set; }
        public List<Item> Items { get; set; }
    }
}