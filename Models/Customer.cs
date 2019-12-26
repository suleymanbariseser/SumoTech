using SumoTech.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Customer
    {
        [Required]
        [Key]
        public int Id { get; set; }
        [Required]
        public String FirstName { get; set; }
        [Required]
        public String LastName { get; set; }
        [Required]
        public String Phone { get; set; }
        [Required]
        public String Email { get; set; }
        public List<Address> Address { get; set; }
        public List<OrderLine> OrderLine { get; set; }
    }
}