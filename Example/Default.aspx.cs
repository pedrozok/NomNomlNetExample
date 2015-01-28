using NomNomlNet;
using NomNomlNet.Enumerates;
using NomNomlNet.Snippets;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Example
{
    public partial class Default1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            List<Node> nodelist = new List<Node>();
            Node n1 = new Node();
            n1.Name = "Start";
            n1.Type = NodeType.Start;

            Node n2 = new Node();
            n2.Name = "Hunger";
            n2.Type = NodeType.State;

            Node n3 = new Node();
            n3.Name = "Buy food?";
            n3.Type = NodeType.Decision;

            Node n4 = new Node();
            n4.Name = "Starve";
            n4.Type = NodeType.Normal;

            Node n5 = new Node();
            n5.Name = "Call apu";
            n5.Type = NodeType.Normal;

            Node n6 = new Node();
            n6.Name = "End";
            n6.Type = NodeType.End;

            Node n7 = new Node();
            n7.Name = "Apu is too busy taking care of is childrens";
            n7.Type = NodeType.Normal;

            nodelist.Add(n1);
            nodelist.Add(n2);
            nodelist.Add(n3);
            nodelist.Add(n4);
            nodelist.Add(n5);
            nodelist.Add(n6);
            nodelist.Add(n7);

            List<Relationship> rellist = new List<Relationship>();
            Relationship r1 = new Relationship();
            r1.Name = "1";
            r1.Source = "Start";
            r1.Target = "Hunger";
            r1.RelationshipType = RelationshipType.Simple;

            Relationship r2 = new Relationship();
            r2.Name = "2";
            r2.Source = "Hunger";
            r2.Target = "Buy food?";
            r2.RelationshipType = RelationshipType.Dependency;

            Relationship r3 = new Relationship();
            r3.Name = "3";
            r3.Source = "Buy food?";
            r3.Target = "Starve";
            r3.Comment = "No";
            r3.RelationshipType = RelationshipType.Comment;

            Relationship r4 = new Relationship();
            r4.Name = "4";
            r4.Source = "Buy food?";
            r4.Target = "Call apu";
            r4.Comment = "Yes";
            r4.RelationshipType = RelationshipType.Comment;


            Relationship r5 = new Relationship();
            r5.Name = "5";
            r5.Source = "Call apu";
            r5.Target = "Apu is too busy taking care of is childrens";
            r5.RelationshipType = RelationshipType.Simple;

            Relationship r6 = new Relationship();
            r6.Name = "6";
            r6.Source = "Starve";
            r6.Target = "End";
            r6.RelationshipType = RelationshipType.Simple;


            Relationship r7 = new Relationship();
            r7.Name = "8";
            r7.Source = "Apu is too busy taking care of is childrens";
            r7.Target = "Starve";
            r7.RelationshipType = RelationshipType.Simple;

            Relationship nota = new Relationship();
            nota.Name = "nota";
            nota.Note = "This is a tricky situation..\r\n i must call master yoda and ask for is opinion!";
            nota.Source = "Hunger";
            nota.Target = "End";
            nota.RelationshipType = RelationshipType.Note;


            rellist.Add(r1);
            rellist.Add(r2);
            rellist.Add(r3);
            rellist.Add(r4);
            rellist.Add(r5);
            rellist.Add(r6);
            rellist.Add(r7);
            rellist.Add(nota);

            //string s = NomGenerator.Generate(nodelist, rellist, new Frame() { name = "Test"});

            string s = NomNomlGenerator.Generate(nodelist, rellist, null);

            var script = "sourceChanged('" + s + "')";

            ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "foo" + Guid.NewGuid(), script, true);
        }
    }
}