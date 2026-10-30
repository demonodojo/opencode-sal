target triple = "x86_64-unknown-linux-gnu"

declare i64 @sal_print_i64(i64)
declare void @sal_matmul_f32(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_softmax_f32(ptr, i64)
declare ptr @sal_load_f32(ptr, ptr)
declare ptr @sal_place_malloc(i64, i32)
declare void @sal_place_free(ptr)
declare ptr @sal_place_copy(ptr, i64, i32)
declare void @sal_on_enter(i32)
declare i64 @sal_place_launches(i64)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @sal_runtime_init(i64, ptr)
declare i64 @sal_argc()
declare ptr @sal_argv(i64)
declare ptr @sal_read_file(ptr)
declare i64 @sal_path_readable(ptr)
declare i64 @sal_write_file(ptr, ptr)
declare i64 @sal_write_png(ptr, i64, i64, ptr)
declare ptr @sal_image_new(i64, i64)
declare i64 @sal_print_str(ptr)
declare i64 @sal_eprint_str(ptr)
declare ptr @sal_getenv(ptr)
declare i64 @sal_mkdir_p(ptr)
declare i64 @sal_str_eq(ptr, ptr)
declare i64 @sal_str_contains(ptr, ptr)
declare i64 @sal_str_len(ptr)
declare ptr @sal_str_concat(ptr, ptr)
declare ptr @sal_str_append(ptr, ptr)
declare ptr @sal_strdup(ptr)
declare ptr @sal_select_str(i64, ptr, ptr)
declare void @sal_free(ptr)
declare i64 @sal_copy_file(ptr, ptr)
declare i64 @sal_copy_self(ptr)
declare i64 @sal_not(i64)
declare i64 @sal_gated_print_str(i64, ptr)
declare i64 @sal_gated_copy_self(i64, ptr)
declare i64 @sal_str_char(ptr, i64)
declare i64 @sal_str_skip(ptr, i64, i64, i64)
declare i64 @sal_str_hash(ptr, i64)
declare ptr @sal_map_new()
declare i64 @sal_map_get(ptr, ptr)
declare i64 @sal_map_put(ptr, ptr, i64)
declare ptr @sal_ir_text(ptr)
declare ptr @sal_lex_src(ptr)
declare ptr @sal_str_slice(ptr, i64, i64)
declare ptr @sal_int_to_str(i64)
declare ptr @sal_char_to_str(i64)
declare ptr @sal_vec_new()
declare i64 @sal_vec_push(ptr, i64)
declare i64 @sal_vec_get(ptr, i64)
declare i64 @sal_vec_set(ptr, i64, i64)
declare i64 @sal_vec_len(ptr)
declare void @sal_vec_free(ptr)
declare ptr @sal_list_new()
declare ptr @sal_list_push(ptr, i64)
declare i64 @sal_list_len(ptr)
declare i64 @sal_list_get(ptr, i64)
declare i64 @sal_clang(ptr, ptr)
declare ptr @sal_realpath(ptr)
declare i64 @sal_clang_obj(ptr, ptr)
declare i64 @sal_link_objs(ptr, ptr)
declare ptr @sal_tmp_path(ptr)
declare ptr @sal_exec_capture(ptr, ptr)
declare i64 @sal_exec_compile(ptr, ptr, ptr)
declare i64 @sal_gated_exec_compile(i64, ptr, ptr, ptr)
declare void @sal_instrument_init()
declare void @sal_instrument_shutdown()
declare ptr @sal_instrument_malloc(i64, i32, ptr)
declare void @sal_instrument_alloc(ptr, i64, i32, ptr)
declare void @sal_instrument_free(ptr)
declare void @sal_instrument_check_f32(ptr, i64, ptr)
declare void @sal_instrument_check_ptr(ptr, i64, i32, ptr)
declare void @sal_instrument_check_index(i64, i64, ptr)
declare ptr @sal_dict_new(i64, i64)
declare ptr @sal_dict_put(ptr, ptr, i64)
declare i64 @sal_dict_get(ptr, ptr)

@.site.alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.site.matmul = private unnamed_addr constant [7 x i8] c"matmul\00"
@.site.load = private unnamed_addr constant [5 x i8] c"load\00"
@.site.softmax = private unnamed_addr constant [8 x i8] c"softmax\00"
@.site.access = private unnamed_addr constant [7 x i8] c"access\00"
@.site.index = private unnamed_addr constant [6 x i8] c"index\00"

@.str.1 = private unnamed_addr constant [2 x i8] c"\22\00"
@.str.2 = private unnamed_addr constant [7 x i8] c"event:\00"
@.str.3 = private unnamed_addr constant [7 x i8] c" text:\00"
@.str.4 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.5 = private unnamed_addr constant [12 x i8] c"event:done\0A\00"

define i64 @json_esc(i64 %s) {
entry:
  %t1 = ptrtoint ptr @.str.1 to i64
  %cast1 = inttoptr i64 %t1 to ptr
  %cast2 = inttoptr i64 %s to ptr
  %t2_p = call ptr @sal_str_concat(ptr %cast1, ptr %cast2)
  %t2 = ptrtoint ptr %t2_p to i64
  %t3 = ptrtoint ptr @.str.1 to i64
  %cast3 = inttoptr i64 %t2 to ptr
  %cast4 = inttoptr i64 %t3 to ptr
  %t4_p = call ptr @sal_str_append(ptr %cast3, ptr %cast4)
  %t4 = ptrtoint ptr %t4_p to i64
  ret i64 %t4
}
define i64 @json_emit_line(i64 %kind, i64 %payload) {
entry:
  %t1 = ptrtoint ptr @.str.2 to i64
  %cast1 = inttoptr i64 %t1 to ptr
  %cast2 = inttoptr i64 %kind to ptr
  %t2_p = call ptr @sal_str_concat(ptr %cast1, ptr %cast2)
  %t2 = ptrtoint ptr %t2_p to i64
  %t3 = ptrtoint ptr @.str.3 to i64
  %cast3 = inttoptr i64 %t2 to ptr
  %cast4 = inttoptr i64 %t3 to ptr
  %t4_p = call ptr @sal_str_append(ptr %cast3, ptr %cast4)
  %t4 = ptrtoint ptr %t4_p to i64
  %t5 = call i64 @json_esc(i64 %payload)
  %cast5 = inttoptr i64 %t4 to ptr
  %cast6 = inttoptr i64 %t5 to ptr
  %t6_p = call ptr @sal_str_append(ptr %cast5, ptr %cast6)
  %t6 = ptrtoint ptr %t6_p to i64
  %t7 = ptrtoint ptr @.str.4 to i64
  %cast7 = inttoptr i64 %t6 to ptr
  %cast8 = inttoptr i64 %t7 to ptr
  %t8_p = call ptr @sal_str_append(ptr %cast7, ptr %cast8)
  %t8 = ptrtoint ptr %t8_p to i64
  ret i64 %t8
}
define i64 @json_emit_done() {
entry:
  %t1 = ptrtoint ptr @.str.5 to i64
  ret i64 %t1
}
define i64 @main(i64 %argc, ptr %argv) {
  call void @sal_runtime_init(i64 %argc, ptr %argv)
  ret i64 0
}
