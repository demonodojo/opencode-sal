target triple = "x86_64-unknown-none-elf"

%SalBytes = type { ptr, i64 }
@sal_bytes_oob = private unnamed_addr constant [20 x i8] c"bytes: out of bounds"

declare i64 @sal_print_i64(i64)
declare void @sal_panic(ptr)
declare void @sal_bytes_check(i64, i64, i64)
declare i64 @sal_os_syscall(i64, i64, i64, i64, i64, i64, i64)
declare void @sal_matmul_f32(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_matmul_f16(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_matmul_bf16(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_qmatmul_f32(ptr, ptr, ptr, ptr, i64, i64, i64, i64)
declare void @sal_attention_f32(ptr, ptr, ptr, ptr, i64, i64, i64, i64, i64)
declare void @sal_tensor_write_row_f32(ptr, i64, ptr, i64)
declare void @sal_tensor_write_rows_f32(ptr, i64, ptr, i64, i64)
declare void @sal_softmax_f32(ptr, i64)
declare void @sal_softmax_axis_f32(ptr, i64, i64)
declare void @sal_silu_f32(ptr, ptr, i64)
declare void @sal_rope_f32(ptr, i64, i64, i64)
declare void @sal_rms_norm_f32(ptr, ptr, ptr, i64, double)
declare i64 @sal_argmax_axis_f32(ptr, i64)
declare void @sal_region_begin(i64, i64)
declare void @sal_region_end(i64)
declare void @sal_tensor_bin_f32(i32, ptr, ptr, ptr, i64, i32, double)
declare void @sal_tensor_cmp_f32(i32, ptr, ptr, ptr, i64, i32, double)
declare void @sal_tensor_neg_f32(ptr, ptr, i64)
declare void @sal_tensor_not_i8(ptr, ptr, i64)
declare i64 @sal_mask_select_count(ptr, i64)
declare void @sal_tensor_select_f32(ptr, ptr, ptr, i64)
declare void @sal_tensor_select_i8(ptr, ptr, ptr, i64)
declare ptr @sal_list_select(ptr, ptr, i64)
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
declare i64 @sal_str_bytes(ptr)
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
declare ptr @sal_str_from_int(i64)
declare i64 @sal_str_as_int(ptr)
declare i64 @sal_str_to_f64_bits(ptr)
declare ptr @sal_f64_bits_to_str(i64)
declare i64 @sal_now_ns()
declare ptr @sal_vec_new()
declare i64 @sal_vec_push(ptr, i64)
declare i64 @sal_vec_get(ptr, i64)
declare i64 @sal_vec_set(ptr, i64, i64)
declare i64 @sal_vec_len(ptr)
declare void @sal_vec_free(ptr)
declare ptr @sal_bytes_new(i64)
declare i64 @sal_bytes_len(ptr)
declare i64 @sal_bytes_fill(ptr, i64, i64, i64)
declare i64 @sal_bytes_fill_u32(ptr, i64, i64, i64)
declare i64 @sal_bytes_copy(ptr, i64, ptr, i64, i64)
declare i64 @sal_str_bytes_copy(ptr, i64, ptr)
declare ptr @sal_bytes_to_str(ptr)
declare ptr @sal_bytes_view(ptr, i64, i64)
declare ptr @sal_bytes_view_mem(i64, i64)
declare i64 @sal_bytes_ptr(ptr)
declare ptr @sal_list_new()
declare ptr @sal_list_new_typed(i64)
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

define i64 @nr_read() {
entry:
  %t1 = add i64 0, 1
  ret i64 1
}
define i64 @nr_write() {
entry:
  %t1 = add i64 0, 2
  ret i64 2
}
define i64 @nr_open() {
entry:
  %t1 = add i64 0, 3
  ret i64 3
}
define i64 @nr_close() {
entry:
  %t1 = add i64 0, 4
  ret i64 4
}
define i64 @nr_stat() {
entry:
  %t1 = add i64 0, 6
  ret i64 6
}
define i64 @nr_getdents() {
entry:
  %t1 = add i64 0, 7
  ret i64 7
}
define i64 @nr_mkdir() {
entry:
  %t1 = add i64 0, 8
  ret i64 8
}
define i64 @nr_unlink() {
entry:
  %t1 = add i64 0, 9
  ret i64 9
}
define i64 @nr_wait() {
entry:
  %t1 = add i64 0, 11
  ret i64 11
}
define i64 @nr_spawn_io() {
entry:
  %t1 = add i64 0, 22
  ret i64 22
}
define i64 @nr_sleep_ms() {
entry:
  %t1 = add i64 0, 13
  ret i64 13
}
define i64 @nr_uptime_ms() {
entry:
  %t1 = add i64 0, 28
  ret i64 28
}
define i64 @nr_tcp_connect() {
entry:
  %t1 = add i64 0, 29
  ret i64 29
}
define i64 @nr_tcp_listen() {
entry:
  %t1 = add i64 0, 30
  ret i64 30
}
define i64 @nr_tcp_accept() {
entry:
  %t1 = add i64 0, 31
  ret i64 31
}
define i64 @nr_read_timeout() {
entry:
  %t1 = add i64 0, 32
  ret i64 32
}
define i64 @nr_dns_resolve() {
entry:
  %t1 = add i64 0, 40
  ret i64 40
}
define i64 @nr_kill() {
entry:
  %t1 = add i64 0, 52
  ret i64 52
}
define i64 @nr_rename() {
entry:
  %t1 = add i64 0, 70
  ret i64 70
}
define i64 @nr_getenv() {
entry:
  %t1 = add i64 0, 83
  ret i64 83
}
define i64 @o_RDONLY() {
entry:
  %t1 = add i64 0, 0
  ret i64 0
}
define i64 @o_WRONLY() {
entry:
  %t1 = add i64 0, 1
  ret i64 1
}
define i64 @o_CREAT() {
entry:
  %t1 = add i64 0, 64
  ret i64 64
}
define i64 @ft_file() {
entry:
  %t1 = add i64 0, 1
  ret i64 1
}
define i64 @ft_dir() {
entry:
  %t1 = add i64 0, 2
  ret i64 2
}
define i64 @dirent_size() {
entry:
  %t1 = add i64 0, 272
  ret i64 272
}
define i64 @dirent_off_ino() {
entry:
  %t1 = add i64 0, 0
  ret i64 0
}
define i64 @dirent_off_file_type() {
entry:
  %t1 = add i64 0, 8
  ret i64 8
}
define i64 @dirent_off_name_len() {
entry:
  %t1 = add i64 0, 9
  ret i64 9
}
define i64 @dirent_off_name() {
entry:
  %t1 = add i64 0, 10
  ret i64 10
}
define i64 @spawnio_size() {
entry:
  %t1 = add i64 0, 112
  ret i64 112
}
define i64 @spawnio_off_path_ptr() {
entry:
  %t1 = add i64 0, 0
  ret i64 0
}
define i64 @spawnio_off_path_len() {
entry:
  %t1 = add i64 0, 8
  ret i64 8
}
define i64 @spawnio_off_stdin() {
entry:
  %t1 = add i64 0, 32
  ret i64 32
}
define i64 @spawnio_off_stdout() {
entry:
  %t1 = add i64 0, 40
  ret i64 40
}
define i64 @spawnio_off_stderr() {
entry:
  %t1 = add i64 0, 48
  ret i64 48
}
define i64 @spawnio_off_argv_ptr() {
entry:
  %t1 = add i64 0, 56
  ret i64 56
}
define i64 @spawnio_off_argv_count() {
entry:
  %t1 = add i64 0, 64
  ret i64 64
}
define i64 @spawnio_off_log_fd() {
entry:
  %t1 = add i64 0, 88
  ret i64 88
}
define i64 @sockaddr_size() {
entry:
  %t1 = add i64 0, 8
  ret i64 8
}
