"use strict";(self["webpackChunkvue_cms_admin"]=self["webpackChunkvue_cms_admin"]||[]).push([[333],{9002:function(t,e,i){i.r(e),i.d(e,{default:function(){return c}});var a=function(){var t=this,e=t._self._c;return e("el-card",{staticClass:"table-card"},[e("div",{staticClass:"header",attrs:{slot:"header"},slot:"header"},[e("span",[t._v("标签列表")]),e("el-button",{attrs:{plain:"",type:"primary",icon:"el-icon-circle-plus-outline"},on:{click:function(e){t.insert_dialog_visible=!0}}},[t._v(" 添加标签 ")])],1),e("el-table",{attrs:{data:t.tableData}},[e("el-table-column",{attrs:{prop:"tag_id",label:"#"}}),e("el-table-column",{attrs:{prop:"tag_name",label:"标签名称"}}),e("el-table-column",{attrs:{label:"操作",width:"180"},scopedSlots:t._u([{key:"default",fn:function(i){return[e("el-button",{attrs:{icon:"el-icon-edit",type:"primary",plain:""},on:{click:function(e){return t.openEditDialog(i.row)}}},[t._v("编辑")]),e("el-button",{attrs:{icon:"el-icon-delete",type:"danger",plain:""},on:{click:function(e){return t.handleRemove(i.row.tag_id,i.$index)}}},[t._v("删除 ")])]}}])})],1),e("el-dialog",{attrs:{title:"添加标签",visible:t.insert_dialog_visible},on:{"update:visible":function(e){t.insert_dialog_visible=e},close:function(e){return t.handleDialogClose("insert_form")}}},[e("el-form",{ref:"insert_form",attrs:{rules:t.rules,model:t.insert_form,"label-width":"80px"}},[e("el-form-item",{attrs:{label:"标签名称",prop:"tag_name"}},[e("el-input",{model:{value:t.insert_form.tag_name,callback:function(e){t.$set(t.insert_form,"tag_name",e)},expression:"insert_form.tag_name"}})],1)],1),e("div",{attrs:{slot:"footer"},slot:"footer"},[e("el-button",{on:{click:function(e){t.insert_dialog_visible=!1}}},[t._v("取 消")]),e("el-button",{attrs:{type:"primary"},on:{click:t.handleInsert}},[t._v("确 定")])],1)],1),e("el-dialog",{attrs:{title:"编辑标签",visible:t.edit_dialog_visible},on:{"update:visible":function(e){t.edit_dialog_visible=e},close:function(e){return t.handleDialogClose("edit_form")}}},[e("el-form",{ref:"edit_form",attrs:{rules:t.rules,model:t.edit_form,"label-width":"80px"}},[e("el-form-item",{attrs:{label:"标签名称",prop:"tag_name"}},[e("el-input",{model:{value:t.edit_form.tag_name,callback:function(e){t.$set(t.edit_form,"tag_name",e)},expression:"edit_form.tag_name"}})],1)],1),e("div",{attrs:{slot:"footer"},slot:"footer"},[e("el-button",{on:{click:function(e){t.edit_dialog_visible=!1}}},[t._v("取 消")]),e("el-button",{attrs:{type:"primary"},on:{click:t.handleEdit}},[t._v("保 存")])],1)],1)],1)},s=[],l=(i(7658),i(1803)),r={data(){return{tableData:[],insert_dialog_visible:!1,edit_dialog_visible:!1,insert_form:{tag_name:""},edit_form:{tag_id:"",tag_name:""},currentData:"",rules:{tag_name:[{required:!0,message:"请输入角色名称",trigger:"blur"}]}}},created(){document.title="标签列表",this.loadList()},methods:{async loadList(){let{status:t,data:e}=await l.Vp.list();t&&(this.tableData=e)},handleInsert(){this.$refs.insert_form.validate((async t=>{if(t){let{status:t,msg:e,data:i}=await l.Vp.insert({...this.insert_form});t&&(this.tableData.push({...i,...this.insert_form}),this.insert_dialog_visible=!1,this.$message.success(e))}}))},openEditDialog(t){this.edit_form={...t},this.edit_dialog_visible=!0,this.currentData=t},handleEdit(){this.$refs.edit_form.validate((async t=>{if(t){let{status:t,msg:e}=await l.Vp.edit(this.edit_form.tag_id,{...this.edit_form});t?(this.$message.success(e),this.edit_dialog_visible=!1,Object.assign(this.currentData,this.edit_form)):this.$message.error(e)}}))},async handleRemove(t,e){this.$confirm("此操作将永久删除该标签, 是否继续?",{type:"warning"}).then((async()=>{let{status:i,msg:a}=await l.Vp.remove(t);i&&(this.tableData.splice(e,1),this.$message.success(a))})).catch((()=>{this.$message.info("取消成功")}))},handleDialogClose(t){this.$refs[t].resetFields()}}},n=r,o=i(1001),d=(0,o.Z)(n,a,s,!1,null,"9c292376",null),c=d.exports}}]);
//# sourceMappingURL=tag-list.1b671b82.js.map